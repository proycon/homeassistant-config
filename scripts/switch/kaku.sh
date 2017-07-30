#!/bin/sh
if [ $# -ne 3 ]; then
    echo "Requiring three arguments!" >&2
    exit 2
fi
while [ -f /tmp/43392.lock ]; do
    sleep 0.2
done
touch /tmp/43392.lock
echo "Calling kaku $1 $2 $3" >&2
/home/homeautomation/43392/lights/kaku $1 $2 $3
rm /tmp/43392.lock
