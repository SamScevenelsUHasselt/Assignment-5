#!/usr/bin/python3

ifname = "sim_output.dat"
ofname = "sim_output.qoi"

ifh = open(ifname, "r")
ofh = open (ofname, "wb")


for line in ifh:
    
    line = line.rstrip()
    last_8 = line[-8:]
    print(last_8)
    line_int = int(line, 2)
    ofh.write(line_int.to_bytes(1,byteorder='big'))

ifh.close()
ofh.close()