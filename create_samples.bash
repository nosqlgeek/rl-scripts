#!/bin/bash
#RCLI=redis-cli
RCLI=/opt/redislabs/bin/redis-cli

function usage() {
 echo "Use: create_samples.bash <host> <port> <passwd>"
}

function uuid() {
 id=`python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)'`
 echo $id
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
rm .commands.txt

uid=$(uuid)

for i in `seq 1 1000000`
do
   echo "i = $i"

   echo "SET ${uid}:${i}:0 'Hello world'" >> .commands.txt
   echo "HSET ${uid}:${i}:1 'value' 'Hello world'" >> .commands.txt
   echo "LPUSH ${uid}:${i}:2 'Hello world'" >> .commands.txt
   echo "ZADD ${uid}:${i}:3 1 'Hello world'" >> .commands.txt
   echo "SADD ${uid}:${i}:4 'Hello world'" >> .commands.txt
done

cat .commands.txt | $RCLI -x
