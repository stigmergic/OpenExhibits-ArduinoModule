OpenExhibits-ArduinoModule
==========================

# Setup
This module was written using Adobe's Flash Builder 4.6.  It depends on the OpenExhibits SDK and the as3glue library from http://code.google.com/p/as3glue/.

Included in this project is the "Firmata_RFID" project, necessary for communicating RFID reading from a Innovations ID-12 or ID-20 chip. This must be placed on the arduino in order for the module to be able to communicate with the arduino.

Communication happens over a serial to socket bridge.  Included in this module is the Tinkerproxy software.

Setup consists of placing the firmware on the arduino, discovering the name of the serial port that it is using (this can be accomplished using the arduino software).  In my case the serial port was named "/dev/cu.usbmodem411".  Note this name can change based on which usb port the arduino is plugged into.

The config file for tinkerproxy needs to be updated with this name here are my settings:

```
# Config file for serproxy
# See serproxy's README file for documentation

# Transform newlines coming from the serial port into nils
# true (e.g. if using Flash) or false
newlines_to_nils=false

# on a mac you will need to add this
#serial_device1=/dev/tty.usbserial-A6004osh
serial_device1=/dev/cu.usbmodem411
# Comm ports used
comm_ports=1,2,3,4

# Default settings
comm_baud=115200
comm_databits=8
comm_stopbits=1
comm_parity=none

# Idle time out in seconds
timeout=300

# Port 1 settings (ttyS0)
net_port1=5331

# Port 2 settings (ttyS1)
net_port2=5332

# Port 3 settings (ttyS2)
net_port3=5333

# Port 4 settings (ttyS3)
net_port4=5334

```



