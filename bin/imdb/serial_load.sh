#!/bin/bash


WORKER=${PWD}/worker.sh

set -m

#${WORKER} 1324490 1324500 &
#${WORKER} 1324500 1324510 &
#${WORKER} 1324510 1324530 &
#${WORKER} 1324530 1324560 &
${WORKER} 1324560 1324580 &
${WORKER} 1324580 1324590 &
${WORKER} 1324590 1324600 &
${WORKER} 1324600 1324650 &
${WORKER} 1324650 1324670 &

while [ 1 ] 
do 
  #jobs -l 
  fg 2>/dev/null 
  if [ ${?} -ne 0 ] 
  then
     break
  fi
done

