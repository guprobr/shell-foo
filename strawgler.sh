#!/bin/bash

# Set process to monitor mem usage
STRAWGLER=${1:-"strawberry"};
# Set loop interval (in seconds)
INTERVAL=${2:-30}; 
# Set memory threshold (in percentage)
MEM_THRESHOLD=${3:-20};
export LC_ALL=C;

strawgler_main() {

# Loop continuously, restart process if reaches threshold!
while true; do
  # Get total RAM in Megabytes
  TOTAL_MEM=$(free -m | awk '/Mem:/{print $2}')
  # Get memory in MB used by the monitored process 
  STRAWGLER_MEM=$(ps -eO rss,fname | grep ${STRAWGLER}$ | awk '{sum+=$2} END {print sum/1024}')
  # Calculate memory usage percentage
  MEM_USAGE=$(echo "scale=2; 100 * $STRAWGLER_MEM / $TOTAL_MEM" | bc)
  echo "${STRAWGLER_MEM} MB (${MEM_USAGE}%)";
  ###notify-send -i ${STRAWGLER} -a ${STRAWGLER} "${STRAWGLER_MEM} MB ($MEM_USAGE%)";
  # Check if memory usage exceeds threshold
  if [[ $(echo "$MEM_USAGE >= $MEM_THRESHOLD" | bc -l) -eq 1 ]]; then
    echo "${STRAWGLER} memory usage ($MEM_USAGE%) exceeded threshold. Restarting..."
    notify-send -i ${STRAWGLER} -a ${STRAWGLER} "${STRAWGLER} mem: ($MEM_USAGE%)" "process Exceeded threshold. Restarting!";
    # Send HUP signal to gracefully restart process
    killall -HUP ${STRAWGLER};
    # Wait to allow shutdown
    sleep 1;
    # then Start "${STRAWGLER}" in background
    ${STRAWGLER} &
  fi

  # Wait some time before checking again
  sleep ${INTERVAL};

done

}

## Check if there is an instance already running
if [ $( pgrep -x "$( basename $0 )" | grep -v $$ | wc -l ) -gt 1 ]; then 
    echo "Tried to spawn more than one script, ¡there can be only one!";
    exit 1;
else
    strawgler_main ${1};
fi 
