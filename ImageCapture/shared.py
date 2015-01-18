import Queue
import copy
#from scipy.interpolate import griddata
import numpy
import os

#Base station
if os.name == 'posix':
	BS_COMPORT = '/dev/ttyUSB0'
else:
	BS_COMPORT = 'COM1'
BS_BAUDRATE = 230400
#XBee
#BS_COMPORT = 'COM6'
#BS_BAUDRATE = 57600

motor_gains_set = False
steering_gains_set = False
steering_rate_set = False
pkts = 0
count2deg = 2000.0/(2**15-1)
bytesIn = 0

last_packet_time = 0
readback_timeout = 4 #seconds

imudata = []
statedata = []
dutycycles = []

sensor_pkts = 0
sensor_data = []
sensor_stream = ''
sensor_bits = -1

sensor_queue = Queue.Queue()

data_queue = Queue.Queue()

lastCenter = 0

pyro_frame = [[0]*8]*8
sums = [0]*8

frame_sequence = [[[0]*8]*8]*8

sensorGridApp = None
       
def updateGUI(vals, heatCenter=[0], upsample=1):
    if sensorGridApp is not None:
        
        n_x = len(vals[0])
        n_y = len(vals)
        
        scaled = numpy.array(scale_temp(vals,False,2970,3050))
        #scaled = numpy.array(scale_temp(vals))
        
        if upsample == 1:
            interp = scaled
        else:
            scaled_x, scaled_y = numpy.mgrid[0:1:(n_x*1j), 0:1:(n_y*1j)]
            
            n_x = n_x*upsample
            n_y = n_y*upsample
            
            interp_x, interp_y = numpy.mgrid[0:1:n_x*1j, 0:1:n_y*1j]
            
            interp = griddata((scaled_x.flatten(),scaled_y.flatten()),
                scaled.flatten(),(interp_x,interp_y),method='cubic')
            
            #print vals
            #print interp
        
        #grid = build_sensor_grid(30/upsample,n_x,n_y,shape='square',masters=[],
        #    c_display='pyro',sensors=interp)
        sensorGridApp.frame.main.gridPanel.setSensors(interp)
        
        arrow = []
        val = heatCenter[0] + 300
            
            #arrow.append([[[val-40,600],[val,560]],
            #    [[val,560],[val+40,600]]])
        
        arrow = [[[val-15,580],[val,550]],[[val,550],[val+15,580]]]
        
       # print arrow
        
        sensorGridApp.frame.main.gridPanel.setCuts(arrow)
            
def scale_temp(temps, dynamic=True, min=5000.0, max=0.0):
    scaled = copy.deepcopy(temps)
    
    if dynamic:
        for r in range(len(temps)):
            for c in range(len(temps[r])):
                if temps[r][c] < min:
                    min = temps[r][c]
                
                if temps[r][c] > max:
                    max = temps[r][c]
    
    for r in range(len(scaled)):
        for c in range(len(scaled[r])):
            if scaled[r][c] < min:
                scaled[r][c] = min
                
            if scaled[r][c] > max:
                scaled[r][c] = max
            
            scaled[r][c] = 1.0*(scaled[r][c]-min)/(max-min)
    
    return scaled
