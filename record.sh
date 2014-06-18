#!/bin/bash

/usr/bin/amixer -c 1 set Mic 100
/home/pi/fadecandy/bin/fcserver-rpi &
/usr/bin/arecord -D plughw:1,0 -f S16_LE | /home/pi/pcm_fft.pl