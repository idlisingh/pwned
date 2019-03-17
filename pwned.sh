#!/bin/bash

PASSWORD=$1

if [ -z $PASSWORD ]; then
  echo "usage $0 <password to check>"
  exit 1
fi

SHA1_PASSWORD=`echo -n $PASSWORD | sha1sum | tr a-z A-Z | cut -c 1-40`
SHA1_PASSWORD_PRE=`echo -n $SHA1_PASSWORD | cut -c 1-5`
SHA1_PASSWORD_POST=`echo -n $SHA1_PASSWORD | cut -c 6-40`

FOUND=`curl -s https://api.pwnedpasswords.com/range/$SHA1_PASSWORD_PRE | grep $SHA1_PASSWORD_POST`

if [ "$FOUND" != "" ]; then
  TIMES=`echo $FOUND | sed 's/.*\://g' | sed 's/\n//g' | sed 's/\r//g'`
  echo "Password $PASSWORD found $TIMES times (hash: $SHA1_PASSWORD)"
else
  echo "Password not found"
fi
