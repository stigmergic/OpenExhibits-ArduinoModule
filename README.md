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

Once this is running the module can be added to a OpenExhibits project as in this Main.as:
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

            //debug listen for all events
            addListenerForAllEvents( function(event:Event):void { trace(event); } );    
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

        public function addListenerForAllEvents( listener : Function ) : void{
            _globalListeners[ listener ] = listener;
        }

        public function removeListenerForAllEvents( listener : Function ) : void{
            delete _globalListeners[ listener ];
        }

        override public function dispatchEvent(event:Event):Boolean{
            var result:Boolean = super.dispatchEvent( event );

            for each( var listener : Function in _globalListeners ){
                listener( event );
            }

            return result;
        }   
    }
}
```

