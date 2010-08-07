#!/usr/bin/env bash

curl -X DELETE http://localhost:5984/wiki --silent
curl -X PUT http://localhost:5984/wiki --silent

while read -r line
do
  echo -n $line | curl --silent -H "Content-Type: application/json" --data @- -X POST http://localhost:5984/wiki/
done < test.json
