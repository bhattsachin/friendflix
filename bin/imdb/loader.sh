#!/bin/sh

#tt[7d]

#wget http://www.imdb.com/title/tt0499375  #2007
#wget http://www.imdb.com/title/tt0871510
#wget http://www.imdb.com/title/tt1014672  #2007
#wget http://www.imdb.com/title/tt1288638  #2008
#wget http://www.imdb.com/title/tt2488496
#wget http://www.imdb.com/title/tt3735246
#wget http://www.imdb.com/title/tt4535650
#http://www.imdb.com/title/tt1324059 #2009

set -x
ACC_DIR=/tmp/acc
mkdir -p 
PID=${$}
TS=`date +"%s"`
ACC_FILE="${TS}_${PID}.keep"
touch ${acc_file}

t() {
  #for i in $(seq 1324059 1324159)
  START_TIME=`date +"%s"`
  #for i in $(seq 1324159 1324259)
  #for i in $(seq 1324259 1324269)
  #for i in $(seq 1324269 1324279)
  #for i in $(seq 1324279 1324280)
  #for i in $(seq 1324280 1324290)
  for i in $(seq 1324290 1324490)
  do
    url_="http://www.imdb.com/title/tt$i"
    wget ${url_}
    echo "tt${i}" >> ${ACC_FILE}
  done
}

ts() {
  
  local __now=`date +"%s"`
  if [ -z "${START_TIME}" ]
  then
      START_TIME=${__now}
  fi

  __diff=$((__now - START_TIME))
  __seconds=$((__diff % 60))
  __minutes=$(((__diff / 60) % 60))
  __hours=$((__diff / 3600))

 echo " elapsed time ${__hours}::${__minutes}::${__seconds}"
}


t 
ts

mv ${ACC_FILE} ${ACC_DIR}
