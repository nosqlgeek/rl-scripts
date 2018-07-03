#!/bin/bash
#RCLI=redis-cli
RCLI=/opt/redislabs/bin/redis-cli


function usage() {
 echo "Use: fetch_all.bash <host> <port> <passwd>"
}

host=$1
port=$2
pwd=$3

echo "host = $host"
echo "port = $port"
echo "pwd = $pwd"

if [ "${host}X" == "X" ]
then
  echo "host missing"
  usage
  exit 1
fi

if [ "${port}X" == "X" ]
then
  echo "port missing"
  usage
  exit 1
fi

if [ "${pwd}X" == "X" ]
then
  echo "password missing"
  #usage
  #exit 1
else
  RCLI="$RCLI -a $pwd"
fi

RCLI="$RCLI -h $host -p $port"

count=0
cursor=1

while [ "$cursor" -gt "0" ]
do
	keys=`$RCLI SCAN $cursor MATCH \* COUNT 1000`
	
	i=0

	for k in $keys
	do
  		if [ "0" -eq "$i" ]
  		then
			cursor=$k
     			echo "cursor = $cursor"
  		else
			count=$((count+1))
			echo "count = $count"
     			#echo "key = $k"
			type=`$RCLI TYPE $k`
			#echo "type = $type"

			v="-1"

			if [ "$type" == "hash" ]
			then
			    v=`$RCLI HGETALL $k`
			fi

			if [ "$type" == "list" ]
			then
			    v=`$RCLI LRANGE $k 0 -1`
			fi

			if [ "$type" == "zset" ]
			then
			    v=`$RCLI ZRANGE $k 0 -1`
			fi

			if [ "$type" == "set" ]
			then
			    v=`$RCLI SMEMBERS $k`
			fi

			if [ "$type" == "string" ]
			then
			    v=`$RCLI GET $k`
			fi

			#echo "value = $v"
  		fi
  
  		i=$((i+1))
	done
done
