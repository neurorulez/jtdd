#!/bin/bash

if [ -e ../../mist/*hex ]; then
    for i in ../../mist/*hex; do
        if [ ! -e $(basename $i) ]; then
            if [ -e "$i" ]; then ln -s $i; fi
        fi
    done
fi

MIST=-mist
VIDEO=0
for k in $*; do
    if [ "$k" = -mister ]; then
        echo "MiSTer setup chosen."
        MIST=$k
    fi
    if [ "$k" = -video ]; then
        VIDEO=1
    fi
done

export GAME_ROM_PATH=../../rom/JTDD.rom
export MEM_CHECK_TIME=240_000_000
export BIN2PNG_OPTIONS="--scale"
export CONVERT_OPTIONS="-resize 300%x300%"
GAME_ROM_LEN=$(stat -c%s $GAME_ROM_PATH)
export YM2151=1

if [ ! -e $GAME_ROM_PATH ]; then
    echo Missing file $GAME_ROM_PATH
    exit 1
fi

# Generic simulation script from JTFRAME
echo "Game ROM length: " $GAME_ROM_LEN
../../modules/jtframe/bin/sim.sh $MIST -d GAME_ROM_LEN=$GAME_ROM_LEN \
    -sysname dd -modules ../../modules -d SCANDOUBLER_DISABLE=1 \
    -d STEREO_GAME -d COLORW=5 -d JT51_NODEBUG $*

if [ -e jt51.log ]; then
    ../../modules/jt51/bin/log2txt < jt51.log >/tmp/x
  #  mv /tmp/x jt51.log
fi
