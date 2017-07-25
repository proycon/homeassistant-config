#!/bin/bash

HADIR=/home/homeautomation/homeassistant/
cd $HADIR

if [ ! -d "$HADIR/env" ]; then
    virtualenv --python=python3 env
fi

. env/bin/activate

pip install -U homeassistant

ln -sf scripts master/scripts
ln -sf scripts pi1/scripts
ln -sf scripts pi2/scripts
ln -sf scripts pi3/scripts


