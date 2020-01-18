#!/bin/bash

HADIR=/home/homeautomation/homeassistant/
cd $HADIR

if [ ! -d "$HADIR/env" ]; then
    virtualenv --python=python3 env
fi

. env/bin/activate

pip install -U homeassistant
pip install pycec

ln -sf $HADIR/scripts $HADIR/master/scripts
ln -sf $HADIR/scripts $HADIR/pi1/scripts
ln -sf $HADIR/scripts $HADIR/pi2/scripts
ln -sf $HADIR/scripts $HADIR/pi3/scripts
ln -sf $HADIR/custom_components $HADIR/master/custom_components
ln -sf $HADIR/custom_components $HADIR/pi1/custom_components
ln -sf $HADIR/custom_components $HADIR/pi2/custom_components
ln -sf $HADIR/custom_components $HADIR/pi3/custom_components


