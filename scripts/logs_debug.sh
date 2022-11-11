#!/bin/bash
config=$1
log=$2
tmp=$(mktemp)
tail -1 $log > $tmp
echo >> $tmp
echo "INPUT"
cat $tmp | jq
docker run -i -v "$config:/config.yaml" dolittle/promtail-debug < $tmp | jq
rm $tmp
