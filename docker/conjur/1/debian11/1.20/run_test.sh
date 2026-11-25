#!/bin/bash -l

echo "Step 1. Create admin"
ADMIN_KEY=$(conjurctl account create myConjurAccount|tail -n 1|sed 's/API key for admin: //')
echo "Admin key is $ADMIN_KEY"

echo "Step 2. Login with admin API key"
NEWTOKEN=$(curl -s -H "Accept-Encoding: base64" -d $ADMIN_KEY \
  http://localhost/authn/myConjurAccount/admin/authenticate)
echo "Auth token is $NEWTOKEN"
curl -H "Authorization: Token token=\"$NEWTOKEN\"" \
  http://localhost/whoami && echo

echo "Step 3. Create sample policy"
TEST_USER_KEY=$(curl -s -H "Authorization: Token token=\"$NEWTOKEN\"" \
  -d "$(< /opt/conjur-server/sample_policy.yaml )" \
  http://localhost/policies/myConjurAccount/policy/root|jq -r .created_roles[].api_key)
echo "Test user key is $TEST_USER_KEY"

echo "Step 4. Login as TestUser"
NEWTOKEN=$(curl -s -H "Accept-Encoding: base64" -d $TEST_USER_KEY \
  http://localhost/authn/myConjurAccount/TestUser%40Test/authenticate)
echo "Test user token is $NEWTOKEN"

echo "Step 5. Check if logged successfully"
curl -H "Authorization: Token token=\"$NEWTOKEN\"" \
  http://localhost/whoami && echo

echo "Step 6. Write test secret"
curl -s -H "Authorization: Token token=\"$NEWTOKEN\"" \
  -d "1234567890" \
  http://localhost/secrets/myConjurAccount/variable/Test%2FsecretVar

echo "Step 7. Get test secret from API with temporary token"
GET_VAR=$(curl -s -H "Authorization: Token token=\"$NEWTOKEN\"" \
  http://localhost/secrets/myConjurAccount/variable/Test%2FsecretVar)
if [ "$GET_VAR" != "1234567890" ];then 
  echo "Something went wrong with API!";
  exit 1
else
  echo "secretVar is $GET_VAR"
fi


