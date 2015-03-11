#!/bin/bash
set -e

TEST_DB=hlrdesk_test_db
TEMPLATE_DB=hlrdesk_test_template_db
SCHEMA_FILE=core/db/schema.sql
MOCK_DATA_FILE=core/db/mock-data.sql

export $(./.env.sh)

printf "Creating and populating test database $TEST_DB"
dropdb $TEMPLATE_DB --if-exists > /dev/null
printf "."
createdb $TEMPLATE_DB > /dev/null
printf "."
psql $TEMPLATE_DB < $SCHEMA_FILE > /dev/null
printf "."
psql $TEMPLATE_DB < $MOCK_DATA_FILE > /dev/null
printf "."
dropdb $TEST_DB --if-exists > /dev/null
printf "."
createdb $TEST_DB -T $TEMPLATE_DB > /dev/null
printf " Done!\n"

export NODE_TEST=true
export PGPOOLSIZE=0
export PGDATABASE=$TEST_DB
export TEMPLATE_DB=$TEMPLATE_DB
export PHANTOMJS_EXECUTABLE=$(npm root)/casperjs/node_modules/phantomjs/bin/phantomjs

node --harmony $(npm bin)/istanbul cover _mocha -- --require co-mocha --harmony tests/ "$@"

# NOTE: potential race condition
USED_PORTS=`netstat -lnt | awk '{print $4}' | tail -n+3 | awk -F ":" '{print $NF}' | sort -nr | uniq`

# modified from Chris Down's post on StackExchange
# http://unix.stackexchange.com/a/55918/37560
read lowerPort upperPort < /proc/sys/net/ipv4/ip_local_port_range
while :; do
  port=`expr $(($RANDOM % ($upperPort + 1 - $lowerPort))) + $lowerPort`
  [[ $USED_PORTS =~ $port ]] || break
done

export PORT=$port

echo "Starting server in background on port $PORT"
nohup npm run server -- COME_AND_GET_ME &>nohup.out &

CASPER_STATUS=0
function killserver {
  pkill -f COME_AND_GET_ME
  PKILL_STATUS=$?
  if [[ $CASPER_STATUS -ne  0 ]]; then
    exit $CASPER_STATUS
  fi
  exit $PKILL_STATUS
}
trap killserver EXIT

TIME=5
printf "Sleeping $TIME seconds to ensure server is ready"

for i in `seq 1 $TIME`;
do
  printf "."
  sleep 1
done
printf "\n"

echo "Running CasperJS tests."
echo "Screenshots saved to tests/screenshots/"

$(npm bin)/casperjs test tests/casperjs/*.js || CASPER_STATUS=1 exit

