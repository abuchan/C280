import command
from struct import pack,unpack
import time

import shared
import Queue

#Dictionary of packet formats, for unpack()
pktFormat = { \
    command.TX_DUTY_CYCLE:          'l3f', \
    command.GET_IMU_DATA:           'l6h', \
    command.TX_SAVED_STATE_DATA:    'l3f', \
    command.SET_THRUST_OPEN_LOOP:   '', \
    command.SET_THRUST_CLOSED_LOOP: '', \
    command.SET_PID_GAINS:          '10h', \
    command.GET_PID_TELEMETRY:      '', \
    command.SET_CTRLD_TURN_RATE:    '=h', \
    command.GET_IMU_LOOP_ZGYRO:     '='+2*'Lhhh', \
    command.SET_MOVE_QUEUE:         '', \
    command.SET_STEERING_GAINS:     '5h', \
    command.SOFTWARE_RESET:         '', \
    command.SPECIAL_TELEMETRY:      '=LL'+14*'h', \
    command.ERASE_SECTORS:          '', \
    command.FLASH_READBACK:         '', \
    command.READ_SENSOR_GRID:       'hB', \
    command.SENSOR_GRID_DATA:       'H8s', \
    command.PYROELEC_COMMAND:       'B', \
    command.PYROELEC_FRAME:         '33h', \
    command.PYROELEC_DATA:          'hhhh', \
    }
               
#XBee callback function, called every time a packet is recieved
def xbee_received(packet):
    rf_data = packet.get('rf_data')
    #rssi = ord(packet.get('rssi'))
    #(src_addr, ) = unpack('H', packet.get('source_addr'))
    #id = packet.get('id')
    #options = ord(packet.get('options'))

    status = ord(rf_data[0])
    type = ord(rf_data[1])
    data = rf_data[2:]
    
    #Record the time the packet is received, so command timeouts
    # can be done
    shared.last_packet_time = time.time()
    
    pattern = pktFormat[type]
    
    if (type == command.GET_IMU_DATA):
        datum = unpack(pattern, data)
        if (datum[0] != -1):
            shared.imudata.append(datum)
            print "got datum:",datum
    elif (type == command.TX_SAVED_STATE_DATA):
        datum = unpack(pattern, data)
        if (datum[0] != -1):
            statedata.append(datum)
    elif (type == command.TX_DUTY_CYCLE):
        datum = unpack(pattern, data)
        if (datum[0] != -1):
            dutycycles.append(datum)
    elif (type == command.ECHO):
        print "echo:",status, type, data
    elif (type == command.SET_PID_GAINS):
        print "Set PID gains"
        gains = unpack(pattern, data)
        print gains
        shared.motor_gains_set = True 
    elif (type == command.SET_STEERING_GAINS):
        print "Set Steering gains"
        gains = unpack(pattern, data)
        print gains
        shared.steering_gains_set = True
    elif (type == command.SET_CTRLD_TURN_RATE):
        print "Set turning rate"
        rate = unpack(pattern, data)[0]
        print "degrees: ",shared.count2deg * rate
        print "counts: ", rate
        shared.steering_rate_set = True
    elif (type == command.GET_IMU_LOOP_ZGYRO):
        pp = 2;
        print "Z Gyro Data Packet"
        datum = unpack(pattern, data)
        if (datum[0] != -1):
            for i in range(pp):
                shared.imudata.append(datum[4*i:4*(i+1)] )
    elif (type == command.SPECIAL_TELEMETRY):
        shared.pkts = shared.pkts + 1
        #print "Special Telemetry Data Packet, ",shared.pkts
        datum = unpack(pattern, data)
        datum = list(datum)
        telem_index = datum.pop(0)
        #print "Special Telemetry Data Packet #",telem_index
        if (datum[0] != -1) and (telem_index) >= 0:
            shared.imudata[telem_index] = datum
            shared.bytesIn = shared.bytesIn + (2*4 + 14*2)
    
    elif (type == command.SENSOR_GRID_DATA):
        datum = unpack(pattern, data)
        bits_left = datum[0]
        new_str = datum[1]
        
        if(shared.sensor_bits is -1): #new data stream
            shared.sensor_bits = bits_left
        
        
        
        # append data, check to make sure that we got the next stream
        if(bits_left is not (shared.sensor_bits - shared.sensor_pkts*64)):
            print 'Frame Error'
        
        shared.sensor_pkts = shared.sensor_pkts + 1
        shared.sensor_stream = shared.sensor_stream + new_str
        
        if ( bits_left <= 64 ): # last packet in stream
            sensor_transaction = (shared.sensor_bits, shared.sensor_stream)
            print strToBinList(shared.sensor_stream,shared.sensor_bits)
            shared.sensor_data.append(sensor_transaction)
            shared.sensor_stream = ''
            shared.sensor_pkts = 0
            shared.sensor_bits = -1
            print parseSensorGridData(sensor_transaction)
            
            #shared.updateGUI(parseSensorGridData(sensor_transaction))
    
    elif (type == command.PYROELEC_COMMAND):
        datum = unpack(pattern, data)
        print 'Pyro sensor response:%c' % chr(datum[0])
    
    elif (type == command.PYROELEC_DATA):
        
        #print data
        datum = unpack(pattern, data)
        print '\nPyro data:%d %d %d %d' % datum
        
    elif (type == command.PYROELEC_FRAME):
        datum = unpack(pattern, data)
        
        type = datum[0]
        
        #print 'Received frame type %d' % type
        
        c_i = 0
        
        if type == 0 or type == 1: # single frame, sent in halves
            if type == 0:
                shared.pyro_frame = []
                shared.sums = [0]*8
                
            row = []
            for p in range(1,len(datum)):
                row.append(datum[p])
                shared.sums[c_i] = shared.sums[c_i] + datum[p]
                
                if len(row) == 8:
                    shared.pyro_frame.append(row)
                    row = []
                    c_i = 0
                else:
                    c_i = c_i + 1
            
            if type == 1:
                #for r in range(len(shared.pyro_frame)):
                #    print shared.pyro_frame[r]
                
                #print shared.sums
                
                hc = 0
                total = 0
                max_i = 0
                max_v = 0
                
                filt = 0
                
                for c in range(len(shared.sums)):
                    if shared.sums[c] > max_v:
                        max_i = c
                        max_v = shared.sums[c]
                
                    
                    
                    hc = hc + (100*c-350)*shared.sums[c]
                    #print (100*c-350)*shared.sums[c]
                    total = total + shared.sums[c]
                
                
                center = 64.0*hc/total
                    
                #print 'sum:%f filt:%f' % (center, filt)
                if len(shared.pyro_frame) == 8:
                    #shared.updateGUI(shared.pyro_frame,[center])
                    shared.data_queue.put(shared.pyro_frame)
                    
                
        elif type == 3:
            print data
            print unpack('66B',data)
        
        #elif type == 4: # column sum information
            #print 'Col:%d Sum:%d' % unpack('hh',data[2:6])
            
        elif type >= 100: # frame sequence
            
            half = type % 2
            frame_num = (type-100)/2
            
            
            print 'Frame %d:%d' % (frame_num, half)
            
            if half == 0:
                shared.frame_sequence[frame_num] = []
            
            row = []
            for p in range(1,len(datum)):
                row.append(datum[p])
                if len(row) == 8:
                    shared.frame_sequence[frame_num].append(row)
                    row = []
            
            if half == 1:
                #for r in range(len(shared.frame_sequence[frame_num])):
                #    print shared.frame_sequence[frame_num]
                
                shared.updateGUI(shared.frame_sequence[frame_num],2)
    else:    
        pass
        