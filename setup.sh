#!/bin/bash

HADIR=/home/homeautomation/homeassistant/
cd $HADIR

if [ ! -d "$HADIR/env" ]; then
    virtualenv --python=python3 env
fi

. env/bin/activate

pip install -U homeassistant

ln -sf $HADIR/scripts master/scripts
ln -sf $HADIR/scripts pi1/scripts
ln -sf $HADIR/scripts pi2/scripts
ln -sf $HADIR/scripts pi3/scripts


