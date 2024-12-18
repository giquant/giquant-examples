#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: ./dwnl.sh cot|cothist"
  exit
fi

python3 -m giquant.trade.dwnl $1 /var/www/data
