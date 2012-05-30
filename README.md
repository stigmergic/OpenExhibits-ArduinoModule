OpenExhibits-ArduinoModule
==========================

# Setup
This module was written using Adobe's Flash Builder 4.6.  
It depends on the [OpenExhibits SDK](http://openexhibits.org/downloads/sdk/)  and the [as3glue](http://code.google.com/p/as3glue/) library.

Included in this project is the "Firmata_RFID" project, necessary for communicating RFID reading from a Innovations ID-12 or ID-20 chip. This must be placed on the arduino in order for the module to be able to communicate with the arduino.

Communication happens over a serial to socket bridge.  Included in this module is the [TinkerProxy](http://code.google.com/p/tinkerit/wiki/TinkerProxy) software.

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

Once this is running the module can be added to a OpenExhibits project as in this Main.as.  The main thing to notice is the addition of the ArduinoViewer and ArduinoToCMLMapper objects.  These are responsible for the module and its Graphic interface.  

I developed this project on the Arduino Mega.  Other Arduino boards will have different numbers of pins.  You can select which pins are made active by editing the ArduinoViewer.as file directly or setting the variables and calling arduino.initArduino().  This will select which pins are read, it is likely a performance boost to only activate the analog pins that you will actually be using.  However by default I have activated all pins for my board. 

```
package 
{
    import ArduinoViewer;

    import com.gestureworks.cml.core.CMLObjectList;
    import com.gestureworks.components.CMLDisplay;
    import com.gestureworks.core.GestureWorks;
    import com.gestureworks.core.TouchSprite;
    import com.gestureworks.events.GWGestureEvent;

    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.utils.Dictionary;

    CMLDisplay;

    [SWF(width = "1024", height = "768", backgroundColor = "0x000000", frameRate = "60")]

    public class Main extends GestureWorks
    {
        private var _viewer:ArduinoViewer;
        private var _mapper:ArduinoToCMLMapper;

        private var _globalListeners : Dictionary;

        public function Main():void 
        {
            super();
            settingsPath = "library/cml/my_application.cml";

            _globalListeners = new Dictionary();

            //Arduino viewer communicates with arduino and allows for listeners to register
            viewer = new ArduinoViewer();
            addChild(viewer);

            //Tracks mapper objects that turns arduino events into changes in CML object property
            mapper = new ArduinoToCMLMapper(viewer);
            mapper.x = 175;
            addChild(mapper);

        }

        public function get mapper():ArduinoToCMLMapper
        {
            return _mapper;
        }

        public function set mapper(value:ArduinoToCMLMapper):void
        {
            _mapper = value;
        }

        public function get viewer():ArduinoViewer
        {
            return _viewer;
        }

        public function set viewer(value:ArduinoViewer):void
        {
            _viewer = value;
        }

    }
}
```

#Wiring up the Innovations ID12 RFID chip
##The RFID chip has pins numbered from 1 to 11 as follows:
1. GND -- connect to GND
2. RST -- connect to 5V to operate, GND to reset, using the Firmata_RFID connect this to digital pin 52 and the app will automatically power cycle after each read in order to detect presence of the card.
3. ANT (unused)
4. ANT (unused)
5. CP (unused)
6. NC (unused)
7. FS -- Format select, 5V for wiegand, GND for ASCII (which is what the module uses).  Note in order to actually set the format the 11 pin must be set to GND. I always keep this connected to GND.
8. D1 (unused)
9. D0 -- TTL data line, outputs serial message for the RFID that is read.  In the initial setup this should be connected to digital pin 50.  Other arduinos will differ in the number of pins available.  The pin that is selected for this must support interrupts in order for  the SoftwareSerial library to work. See here for more: http://arduino.cc/hu/Reference/SoftwareSerial
10. BZ -- High when an RFID is read, can be hooked up to an LED or buzzer to sound when a card is read.
11. 5V -- Power source 5Volts

I purchased the ID-20 from http://sparkfun.com along with a breakout board for the ID-12 (which is compatiable with ID-20).  I recommend this breakout as it made attaching wires very simple even for my limited soldering abilities.

#wiring a switch
http://arduino.cc/en/Tutorial/Button
Digital switches require a pull down resistor so that they do not float when the switch is turned off.  I used a 10Kohm resistor connected to the reading side of the switch like so:

PWR --- switch --- lead to digital pin --- 10Kohm resistor --- GND

#wiring a potentiometer
http://arduino.cc/en/Tutorial/AnalogReadSerial
Potentiometers are easy to wire. I use a 10Kohm pot and it works well.  Pots have three connectors.  Usually the two outside connectors go to ground and power and the middle goes to an analog pin on the arduino.  Whci wire is connected to ground and vice versa will select whether the reading is low clockwise or counter clockwise.
