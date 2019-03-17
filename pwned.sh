#!/bin/bash

if [ -z $1 ]; then
  echo "usage $0 <password in plain text OR file with all passwords"
  exit 1
fi

# Checks if the password has been breached by using haveibeenpwned API
check_password()
{
  PASSWORD=$1
  SHA1_PASSWORD=`echo -n $PASSWORD | sha1sum | tr a-z A-Z | cut -c 1-40`
  SHA1_PASSWORD_PRE=`echo -n $SHA1_PASSWORD | cut -c 1-5`
  SHA1_PASSWORD_POST=`echo -n $SHA1_PASSWORD | cut -c 6-40`

  FOUND=`curl -s https://api.pwnedpasswords.com/range/$SHA1_PASSWORD_PRE | grep $SHA1_PASSWORD_POST`

  if [ "$FOUND" != "" ]; then
    TIMES=`echo $FOUND | sed 's/.*\://g' | sed 's/\n//g' | sed 's/\r//g'`
    echo "Password $PASSWORD $TIMES times (hash: $SHA1_PASSWORD)"
  else
    echo "Password not found"
  fi
}

if [ -f $1 ]; then
  count=1
  while read -r line
  do
    check_password $line
    if (( count % 5 == 0 )); then
      echo "Sleep for 2 seconds to prevent rate limiting"
      sleep 2
    fi
    count=$((count + 1))
  done < $1
else
  check_password $1
fi
