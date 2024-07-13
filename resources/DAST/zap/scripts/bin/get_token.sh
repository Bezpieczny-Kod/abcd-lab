#!/bin/bash

email=""
password=""

while [[ "$#" -gt 0 ]]; do
   case $1 in
       --email) email="$2"; shift ;;
       --password) password="$2"; shift ;;
       *) echo "Unknown option: $1"; exit 1 ;;
   esac
   shift
done

if [ -z "$email" ] || [ -z "$password" ]; then
   echo "Failure: You must provide both (--email) and (--password)"
   exit 1
fi

RESPONSE=$(curl 'http://localhost:3000/rest/user/login' -s \
    -H 'Content-Type: application/json' \
    --data-raw '{"email":"joe@example.com","password":"12345678"}')

TOKEN=$(echo $RESPONSE | jq -r '.authentication.token')

if [ -z "$TOKEN" ]; then
    echo "Failed to fetch token!"
    exit 1
fi

echo $TOKEN