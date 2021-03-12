// Copyright 2021 Google Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const API_PORT = process.env.API_PORT || 8080;
const MONGODB_HOST = process.env.MONGODB_HOST || "localhost";
const MONGODB_USERNAME = process.env.MONGODB_USERNAME || "";
const MONGODB_PASSWORD = process.env.MONGODB_PASSWORD || "";
const MONGODB_PORT = process.env.MONGODB_PORT || 27017;
const MONGODB_NAME = process.env.MONGODB_NAME || "test";

const express = require('express')
const app = express()
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const mongooseOpts = {
  useNewUrlParser: true,
  useUnifiedTopology: true
};
const connectionString = `mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_HOST}:${MONGODB_PORT}/${MONGODB_NAME}`;

mongoose.connect(connectionString, mongooseOpts).then(
  () => { console.log('Connected.')},
  err => {
    console.log('Failed to connect.');
    process.exit(1);
  }
);
const Pet = mongoose.model('Pet', { name: String });

app.use(bodyParser.json())

app.get('/', function (req, res) {
  const hostname = req.hostname;

  res.json({
    name: 'Google Cloud Marketplace - Sample API',
    resources: ['/pets'],
    docs: `http://${hostname}/#api-usage`
  })
})

app.post('/pets', function (req, res) {
  if (!req.body.name) {
    return res.status(400).send({
      message: 'Field "name" is required'
    });
  }

  const pet = new Pet({ name: req.body.name });
  pet.save().then(() => {
      res.json(pet);
  });
})

app.get('/pets', function (req, res) {
  Pet.find({}, (err, pets) => {
    res.json(pets)
  })
})

// Add other routes

app.listen(API_PORT, () => {
  console.log(`Starting on Port: ${API_PORT}`)
})
