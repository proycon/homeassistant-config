#!/bin/bash
echo "Running: irsend SEND_ONCE $1 $2">&2
irsend SEND_ONCE $1 $2 > /tmp/irsend.log 2>/tmp/irsend.err
