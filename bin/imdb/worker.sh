#!/bin/bash

#set -x
ACC_DIR=/tmp/acc_worker
mkdir -p ${ACC_DIR}
PID=${$}
TS=`date +"%s"`
ACC_FILE="${TS}_${PID}.keep"
START_TIME=`date +"%s"`
F=${1}
L=${2}

touch ${ACC_FILE}

for i in $(seq ${F} ${L})
do
  url_="http://www.imdb.com/title/tt$i"
  echo $url_
  wget ${url_}
  echo "tt${i}" >> ${ACC_FILE}
done
mv ${ACC_FILE} ${ACC_DIR}

__now=`date +"%s"`
__diff=$((__now - START_TIME))
__seconds=$((__diff % 60))
__minutes=$(((__diff / 60) % 60))
__hours=$((__diff / 3600))

echo " elapsed time ${__hours}::${__minutes}::${__seconds}"
