import numpy as np
import command 
from struct import *
import time,sys
from xbee import XBee
import serial
import glob
from math import ceil,floor
from callbackFunc import xbee_received
import shared
import datetime
import threading
import Queue
import os

from VideoCapture import Device

DEST_ADDR = '\x20\x72'

RESET_ROBOT = True
USE_SERIAL = True

if USE_SERIAL:
    try:
        ser = serial.Serial(shared.BS_COMPORT, shared.BS_BAUDRATE, \
            timeout=3, rtscts=0)
    except serial.serialutil.SerialException:
        print "Could not open serial port:",shared.BS_COMPORT
        sys.exit()
    
    xb = XBee(ser, callback = xbee_received)
            
def xb_send(status, type, data):
    if USE_SERIAL:
        payload = chr(status) + chr(type) + ''.join(data)
        xb.tx(dest_addr = DEST_ADDR, data = payload)

def resetRobot():
    if USE_SERIAL:
        xb_send(0, command.SOFTWARE_RESET, pack('h',0))

    # Read commands from the command line interface and put them on the command queue
class commandListener(threading.Thread):
  def __init__(self, command_queue):
    threading.Thread.__init__(self)
    self.command_queue = command_queue
    
  def run(self):
    while(True):
      cmd = sys.stdin.readline()
      if cmd:
        self.command_queue.put(cmd)
      else: #eof
        self.command_queue.put('quit') #this will make the main thread exit
        sys.exit(0)
        
def main():

    if RESET_ROBOT:
        print "Resetting robot..."
        resetRobot()
        time.sleep(1)
        print 'Reset Done'
        
    command_queue = Queue.Queue()
    cl = commandListener(command_queue)
    cl.daemon = True
    cl.start()
    
    try:
        cam = Device()
    except:
        print 'Failed to construct webcam device'
        cam = None
    
    files = glob.glob('../../data/*.png')
    
    
    if not files == []:
        files.sort()
        file_num = int(files[-1][-8:-4])+1
    else:
        file_num = 1
    
    while(True):
        time.sleep(0.2)
    
        if(not command_queue.empty()):
            cmd = command_queue.get().split()

            if(len(cmd)>0):
                if(cmd[0] == 'c'):
                    while not shared.data_queue.empty():
                        shared.data_queue.get()
                        
                    xb_send(0, command.PYROELEC_COMMAND, pack('B',ord('k')))
                    
                    increment = False
                    
                    if not cam == None:
                        cam.saveSnapshot('../../data/img_%04d.png' % file_num)
                        increment = True
                        
                    last_time = time.time()
                    therm_data = None
                    
                    while(time.time() - last_time < 1.0 and therm_data == None):
                        if not shared.data_queue.empty():
                            therm_data = shared.data_queue.get()
                    
                    if therm_data == None:
                        print 'Thermal Data Timeout'
                    else:
                        tf = open('../../data/therm_%04d.txt'%file_num,'w')
                        for row in therm_data:
                            tf.write('%s\n' % row.__str__().strip('[]'))
                        tf.close()
                        increment = True
                    
                    if increment:
                        file_num = file_num + 1
                    
                    
                elif(cmd[0] == 'a'):
                    print 'Echo Test'
                    xb_send(0, command.PYROELEC_COMMAND, pack('B',ord('a')))
                            
                elif(cmd[0] == 'x' or cmd[0] == 'q'):
                    # quit
                    break
            else:
                pass
            
    
    print "Ctrl + C to exit"

    while True:
        try:
            time.sleep(1)
            #print ".",
        except KeyboardInterrupt:
            break

    if USE_SERIAL:
        xb.halt()
        ser.close()

    print "Done"


#Provide a try-except over the whole main function
# for clean exit. The Xbee module should have better
# provisions for handling a clean exit, but it doesn't.
if __name__ == '__main__':
    try:
        main()
    
    except KeyboardInterrupt:
        print "\nRecieved Ctrl+C, exiting."
        
        if USE_SERIAL:
            xb.halt()
            ser.close()
    #except Exception as args:
    #    print "\nGeneral exception:",args
    #    print "Attemping to exit cleanly..."
    #    xb.halt()
    #    ser.close()
    except serial.serialutil.SerialException:
        xb.halt()
        ser.close()