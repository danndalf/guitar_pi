sudo /usr/bin/amixer -c 1 set Mic 100
#sudo /home/pi/fadecandy/bin/fcserver-rpi 2>&1 &
#/home/pi/lcd_bridge.py &
#/home/pi/mandelbrot.pl -0.6209 0.6555 0.3727
#/usr/bin/arecord -D plughw:1,0 -f S16_LE | /home/pi/pcm_fft.pl 2>&1 >> /home/pi/messages &
/usr/bin/arecord -D plughw:1,0 -f S16_LE | /home/pi/pcm_fft_serial.pl 2>&1 &
