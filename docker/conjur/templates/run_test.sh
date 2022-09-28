#!/bin/bash -l

echo "Step 1. Create admin"
ADMIN_KEY=$(conjurctl account create myConjurAccount|tail -n 1|sed 's/API key for admin: //')
gem install xdg -v 2.2.3 >> /dev/null
echo "Admin key is $ADMIN_KEY"

echo "Step 2. Login with admin API key"
conjur init --url $(hostname) -a myConjurAccount
conjur authn login -u admin -p ${ADMIN_KEY}

echo "Step 3. Create sample policy"
TEST_USER_KEY=$(conjur policy load root /opt/conjur-server/sample_policy.yaml | grep api_key | cut -d"\"" -f 4)
echo "Test user key is $TEST_USER_KEY"

echo "Step 4. Login as TestUser"
conjur authn logout
conjur authn login -u TestUser@Test -p ${TEST_USER_KEY}

echo "Step 5. Check if logged successfully"
conjur authn whoami

echo "Step 6. Write test secret"
conjur variable values add Test/secretVar "1234567890"

echo "Step 7. Get test secret from API with temporary token"
GET_VAR=$(curl -s -H "$(conjur authn authenticate -H)" http://localhost/secrets/myConjurAccount/variable/Test%2FsecretVar)
if [ "$GET_VAR" != "1234567890" ];then 
  echo "Something went wrong with API!";
  exit 1
else
  echo "secretVar is $GET_VAR"
fi
gem uninstall xdg -x -I >> /dev/null

