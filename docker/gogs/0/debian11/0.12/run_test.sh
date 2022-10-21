#!/bin/bash -l

echo "Step 1. Create testuser"
/app/gogs/gogs admin create-user --name testuser --password testpassword --admin --email test@test.test

echo "Step 2. Get user info"
export TEST_USERNAME=$(curl -s -u "testuser:testpassword" localhost:3000/api/v1/users/testuser/|jq -r .username)
if [ "${TEST_USERNAME}" != "testuser" ];then 
  echo "Something went wrong with API!";
  exit 1
else
  echo "Test user name is $TEST_USERNAME"
fi

echo "Step 3. Create testrepo"
curl -s -u "testuser:testpassword" -H "Content-Type: application/json"  -d "{\"Name\": \"testrepo\"}" localhost:3000/api/v1/admin/users/testuser/repos/ && echo

echo "Step 4. Ger repo info"
export TEST_REPO=$(curl -s -u "testuser:testpassword" localhost:3000/api/v1/repos/testuser/testrepo/|jq -r .clone_url)
if [ "${TEST_REPO}" != "${GOGS_EXTERNAL_URL}testuser/testrepo.git" ];then 
  echo "Something went wrong with API!";
  exit 1
else
  echo "Test repo clone url is $TEST_REPO"
fi

echo "Step 5. Clone test repo"
git clone ${TEST_REPO} /tmp/testrepo/ 2>&1 || true

