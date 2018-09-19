var Db = require('mongodb').Db;
var MongoServer = require('mongodb').Server;
var async = require('async');
var config = require('./config');

var localhost = '127.0.0.1'; //Can access mongo as localhost from a sidecar

var getDb = function(host, done) {
  //If they called without host like getDb(function(err, db) { ... });
  if (arguments.length === 1) {
    if (typeof arguments[0] === 'function') {
      done = arguments[0];
      host = localhost;
    } else {
      throw new Error('getDb illegal invocation. User either getDb(\'options\', function(err, db) { ... }) OR getDb(function(err, db) { ... })');
    }
  }

  var mongoOptions = {};
  host = host || localhost;

  if (config.mongoSSLEnabled) {
    mongoOptions = {
      ssl: config.mongoSSLEnabled,
      sslAllowInvalidCertificates: config.mongoSSLAllowInvalidCertificates,
      sslAllowInvalidHostnames: config.mongoSSLAllowInvalidHostnames
    }
  }

  var mongoDb = new Db(config.database, new MongoServer(host, config.mongoPort, mongoOptions));

  mongoDb.open(function (err, db) {
    if (err) {
      return done(err);
    }

    if(config.username) {
        mongoDb.authenticate(config.username, config.password, function(err, result) {
            if (err) {
              return done(err);
            }

            return done(null, db);
        });
    } else {
      return done(null, db);
    }

  });
};

var replSetGetConfig = function(db, done) {
  db.admin().command({ replSetGetConfig: 1 }, {}, function (err, results) {
    if (err) {
      return done(err);
    }

    return done(null, results.config);
  });
};

var replSetGetStatus = function(db, done) {
  db.admin().command({ replSetGetStatus: {} }, {}, function (err, results) {
    if (err) {
      return done(err);
    }

    return done(null, results);
  });
};

var initReplSet = function(db, hostIpAndPort, done) {
  console.log('initReplSet', hostIpAndPort);

  db.admin().command({ replSetInitiate: {} }, {}, function (err) {
    if (err) {
      return done(err);
    }

    //We need to hack in the fix where the host is set to the hostname which isn't reachable from other hosts
    replSetGetConfig(db, function(err, rsConfig) {
      if (err) {
        return done(err);
      }

      console.log('initial rsConfig is', rsConfig);
      rsConfig.configsvr = config.isConfigRS;
      rsConfig.members[0].host = hostIpAndPort;
      async.retry({times: 20, interval: 500}, function(callback) {
        replSetReconfig(db, rsConfig, false, callback);
      }, function(err, results) {
        if (err) {
          return done(err);
        }

        return done();
      });
    });
  });
};

var replSetReconfig = function(db, rsConfig, force, done) {
  console.log('replSetReconfig', rsConfig);

  rsConfig.version++;

  db.admin().command({ replSetReconfig: rsConfig, force: force }, {}, function (err) {
    if (err) {
      return done(err);
    }

    return done();
  });
};

var addNewReplSetMembers = function(db, addrToAdd, addrToRemove, shouldForce, done) {
  replSetGetConfig(db, function(err, rsConfig) {
    if (err) {
      return done(err);
    }

    removeDeadMembers(rsConfig, addrToRemove);

    addNewMembers(rsConfig, addrToAdd);

    replSetReconfig(db, rsConfig, shouldForce, done);
  });
};

var addNewMembers = function(rsConfig, addrsToAdd) {
  if (!addrsToAdd || !addrsToAdd.length) return;

  var memberIds = [];
  var newMemberId = 0;

  // Build a list of existing rs member IDs
  for (var i in rsConfig.members) {
    memberIds.push(rsConfig.members[i]._id);
  }

  for (var i in addrsToAdd) {
    var addrToAdd = addrsToAdd[i];

    // Search for the next available member ID (max 255)
    for (var i = newMemberId; i <= 255; i++) {
      if (!memberIds.includes(i)) {
        newMemberId = i;
        memberIds.push(newMemberId);
        break;
      }
    }

    // Somehow we can get a race condition where the member config has been updated since we created the list of
    // addresses to add (addrsToAdd) ... so do another loop to make sure we're not adding duplicates
    var exists = false;
    for (var j in rsConfig.members) {
      var member = rsConfig.members[j];
      if (member.host === addrToAdd) {
        console.log("Host [%s] already exists in the Replicaset. Not adding...", addrToAdd);
        exists = true;
        break;
      }
    }

    if (exists) {
      continue;
    }

    var cfg = {
      _id: newMemberId,
      host: addrToAdd
    };

    rsConfig.members.push(cfg);
  }
};

var removeDeadMembers = function(rsConfig, addrsToRemove) {
  if (!addrsToRemove || !addrsToRemove.length) return;

  for (var i in addrsToRemove) {
    var addrToRemove = addrsToRemove[i];
    for (var j in rsConfig.members) {
      var member = rsConfig.members[j];
      if (member.host === addrToRemove) {
        rsConfig.members.splice(j, 1);
        break;
      }
    }
  }
};

var isInReplSet = function(ip, done) {
  getDb(ip, function(err, db) {
    if (err) {
      return done(err);
    }

    replSetGetConfig(db, function(err, rsConfig) {
      db.close();
      if (!err && rsConfig) {
        done(null, true);
      }
      else {
        done(null, false);
      }
    });
  });
};

module.exports = {
  getDb: getDb,
  replSetGetStatus: replSetGetStatus,
  initReplSet: initReplSet,
  addNewReplSetMembers: addNewReplSetMembers,
  isInReplSet: isInReplSet
};
