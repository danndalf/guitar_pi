#!/usr/bin/python
import serial
import time
import os

ser = serial.Serial('/dev/ttyACM0', 115200)
time.sleep(3)
ser.write("Guitarduino\n")

filename = 'messages'
file = open(filename, 'r')

st_results = os.stat(filename)
st_size = st_results[6]
file.seek(st_size)
while 1:
	where = file.tell()
	line = file.readline()
	if not line:
		time.sleep(0.5)
		file.seek(where)
	else:
		ser.write(line)
													
