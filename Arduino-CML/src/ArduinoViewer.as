/** 
 * Uses the as3glue library (http://code.google.com/p/as3glue/)
 * makes connection with tinkerproxy or other serial to socket library
 * communicates with Firmata,  In this case a modified Firmata called
 * Firmata_RFID that sends RFID events as sysex messages.
 * 
 * Software interested in Analog, Digital, or RFID events can register a 
 * listener with the dispatcher object.
 * 
 * This object also provides a view of the current state of the arduino
 * 
 */

package
{
	import com.gestureworks.core.TouchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	import net.eriksjodin.arduino.events.ArduinoSysExEvent;
	
	public class ArduinoViewer extends Sprite
	{
		private var arduino:Arduino;
		private var button:Sprite;
		private var buttonLabel:TextField;
		
		private var status:TextField;
		
		private var ledState:Boolean = false;
		
		public var firstDigitalPin:Number = 2;
		public var lastDigitalPin:Number = 49;
		
		public var HOST:String = "127.0.0.1";
		public var PORT:Number = 5331;
		
		//public var COM:String = "cu.usbmodem411";
		//public var BAUD:Number = 115200;
		
		public var RFID_RX:Number = 50;
		public var RFID_TX:Number = 51;
		public var RFID_RESET_PIN:Number = 52;
		public var RFID_RESET_TIME:Number = 200;
		public var RFID_CONTINOUS_TIMEOUT:Number = 500;
		
		private var rfid_continous_timer:Timer;

		public var firstAnalogPin:Number = 0;
		public var lastAnalogPin:Number = 15;//15;
		
		public var digitalPins:Array = new Array(lastDigitalPin+1);
		public var analogPins:Array = new Array(lastAnalogPin+1);
		
		public var currentRFID:String = ""; 
		public var lastRFID:String = ""; 
				
		private var _dispatcher:ArduinoEventDispatcher;		
		
		public function ArduinoViewer()
		{
			_dispatcher = new ArduinoEventDispatcher();
			
			// Debug trace of events, uncomment to see if you are getting events...
			//_dispatcher.addDigitalEventListener(-1, function(pin:Number, value:Number):void { trace("Digital event for pin: " + pin + " value: " + value);  });
			//_dispatcher.addAnalogEventListener(-1, function(pin:Number, value:Number):void { trace("Analog event for pin: " + pin + " value: " + value);  });
			//_dispatcher.addRFIDEventListener("", function(rfid:String, value:Number):void { trace("RFID event for rfid: " + rfid + " value: " + value); });
			
			
			// get arduino going
			initArduino();			
			
			// setup a message in the dropdown
			status = new TextField();
			status.text = "waiting...\n   Press reset button if this message doesn't change.";
			status.y = 20;
			status.height = 200;
			status.width = 180;
			status.autoSize = "left";
			status.selectable = true;

			
			var format:TextFormat = new TextFormat("fixed-width");
			
			status.setTextFormat(format);
			
			status.background = true;
			status.backgroundColor = 0xCCCCCC;
				
			addChild(createButton());
			addChild(status);
		}

		public function displayComplete():void {
			//entry point after CML parser has finished
			
		}
		
		public function get dispatcher():ArduinoEventDispatcher
		{
			return _dispatcher;
		}

		public function set dispatcher(value:ArduinoEventDispatcher):void
		{
			_dispatcher = value;
		}

		protected function initArduino():void {
			trace("starting connection...");
			try {
				arduino = new Arduino(HOST,PORT);
				//arduino = new Arduino(COM,BAUD);

				arduino.addEventListener(Event.CONNECT,onSocketConnect);
				arduino.addEventListener(Event.CLOSE,onSocketClose);
				arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, firmwareHandler);
				arduino.addEventListener(ArduinoSysExEvent.SYSEX_MESSAGE, sysexHandler);
			
				//pin 13 is used to debug arduino, it is connected to an LED and should be on when the menu is active
				writeButton();
			} catch (e:Error) {
				trace("Error: " + e);
				status.text = e.getStackTrace();
			}

		}

		private function setupArduino():void {
			//arduino.setAnalogPinReporting(0, Arduino.INPUT);
			arduino.resetBoard();
			
			arduino.enableDigitalPinReporting();
			
			var i:Number;
			for (i = firstDigitalPin; i<=lastDigitalPin; i++) {
				if (i == 13) continue; // LED is being used for output
				arduino.setPinMode(i, Arduino.INPUT);
				digitalPins[i] = 0;
			}

			for (i = firstAnalogPin; i<=lastAnalogPin; i++) {
				arduino.setAnalogPinReporting(i, Arduino.ON);
				analogPins[i] = 0;
			}

			//RFID softwareserial pins
			arduino.setPinMode(RFID_RX, Arduino.INPUT);
			arduino.setPinMode(RFID_TX, Arduino.OUTPUT);
			//Reset PIN allows for card presence detection
			arduino.setPinMode(RFID_RESET_PIN, Arduino.OUTPUT);
			writeRFIDResetPin(Arduino.HIGH);
			
			arduino.addEventListener(ArduinoEvent.ANALOG_DATA, analogHandler);
			arduino.addEventListener(ArduinoEvent.DIGITAL_DATA, digitalHandler);
		}
		
		private function onSocketConnect(e:Object):void {
			trace("Socket connected!");
			arduino.requestFirmwareVersion();
		}
		
		private function onSocketClose(e:Object):void {
			trace("Socket closed!");
		}
		
		protected function sysexHandler(event:ArduinoSysExEvent):void
		{
			//trace(event);
			var value:String = event.data.toString();
			//trace("value: " + value);
			
			if (value.substring(0,5) == "RFID:") {
				rfidHandler(value);				
			}
			
			frameHandler(event);
		}
		
		protected function firmwareHandler(event:ArduinoEvent):void
		{
			trace(event);
			
			setupArduino();
			
			frameHandler(event);
		}
		
		protected function digitalHandler(event:ArduinoEvent):void
		{
			var pin:Number = event.pin;
			var value:Number = event.value;

			digitalPins[pin] = value;
			_dispatcher.dispatchDigitalEvent(pin, value);
			
			frameHandler(event);
		}
		
		protected function analogHandler(event:ArduinoEvent):void
		{
			var pin:Number = event.pin;
			var value:Number = event.value;
			
			analogPins[pin] = value/1023.0;
			_dispatcher.dispatchAnalogEvent(pin, analogPins[pin]);

			frameHandler(event);
		}
		
		private function rfidHandler(value:String):void {
			var vals:Array = value.substring(5).split(':');
			if (vals.length == 2) {
				if (vals[1]=='1') {
					currentRFID = vals[0];
					if (lastRFID != currentRFID) {
						_dispatcher.dispatchRFIDEvent(lastRFID, 0);
						lastRFID = currentRFID; 
					}

					writeRFIDResetPin(Arduino.LOW);
					var myTime:Timer = new Timer(RFID_RESET_TIME, 1);
					myTime.addEventListener(TimerEvent.TIMER, function():void {
						if (rfid_continous_timer != null && rfid_continous_timer.running) {
							rfid_continous_timer.reset();
						} else {
							rfid_continous_timer = new Timer(RFID_CONTINOUS_TIMEOUT, 1);
							rfid_continous_timer.addEventListener(TimerEvent.TIMER, function():void {
								_dispatcher.dispatchRFIDEvent(lastRFID, 0);
								currentRFID = "";
							});
						}
							
						rfid_continous_timer.start();
						writeRFIDResetPin(Arduino.HIGH); 
					});
					myTime.start();
					
					_dispatcher.dispatchRFIDEvent(currentRFID, 1); 
				}
			}
		}

		
		private function updateButton():void {
			buttonLabel.text = "PIN 13 LED " + (ledState?"ON":"OFF");		
			buttonLabel.textColor = 0xFFFFFF;
			
			buttonLabel.background = true;
			buttonLabel.backgroundColor = ledState?0x00CC00:0xCC0000;
			
			if (status) status.visible = ledState;
		}
		
		private function writeButton():void {
			try {

				arduino.setPinMode(13, Arduino.OUTPUT);
				arduino.writeDigitalPin(13, ledState?Arduino.HIGH:Arduino.LOW);	
			
			} catch (e:Error) {
				trace('Error: ' + e + "\ntype: " + e.errorID + " " );
				
				initArduino();
				
				//possible endless loop here. writeButton is called from initArduino... 			
			}
		}
		
		private function createButton():Sprite {
			button = new Sprite();
			buttonLabel = new TextField();
			buttonLabel.height = 20;
			buttonLabel.selectable = false;
			
			updateButton();
			button.addChild(buttonLabel);
			
			
			button.addEventListener(MouseEvent.CLICK, toggleHandler);
			return button;
		}
		
		private function toggleButton():void {
			ledState = !ledState;
			
			writeButton();
			updateButton();		
		}
		
		private function toggleHandler(event:Event):void {	
			toggleButton();

			trace("Button: " + buttonLabel.text);			
		}


		private function digitalPinState():String {
			var status:String = "";
			
			for (var i:int=0; i<=lastDigitalPin; i++) {
				if ((i<firstDigitalPin) || (i == 13)) {
					status += 'L';
					continue; // LED is being used for output
				}
				
				try {
					//status += arduino.getDigitalData(i).toString();
					status += digitalPins[i].toString();
				} catch (e:Error) {
					status += '@';
				}
				status += ((i+1) % 10 == 0) ? "\n" : "";
			}
			status += '\n';
			
			return status;
		}
		
		private function analogPinState():String {
			var status:String = "";
			for (var i:int=firstAnalogPin; i <= lastAnalogPin; i++) {
				try {
					//status += arduino.getAnalogData(i).toString() + " ";
					status += numberFormat(analogPins[i], 3, true) + " ";
				} catch (e:Error) {
					status += '@\n' ;
				}				
				status += ( ((i+1) % 5 == 0) ? "\n" : "" );
			}
			
			return status;
		}
		
		private function pinState():String {
			var status:String = digitalPinState();
			status += analogPinState();
			return status;
		}

		private function writeRFIDResetPin(mode:int):void {
			try {
				arduino.writeDigitalPin(RFID_RESET_PIN, mode);
			} catch (e:Error) {
				trace('Error: ' + e + "\ntype: " + e.errorID + " " );
				initArduino();
				//possible endless loop here. writeButton is called from initArduino... 	
			}

		}
		
		private function frameHandler(event:Event):void {
			//update view based on current state
			writeButton();
			updateButton();
												
			status.text = "";
			status.appendText( "Firmware: " + arduino.getFirmwareVersion() + "\n");
			status.appendText(  pinState() + "\n" );
			status.appendText( "current RFID: " + currentRFID + "\n" );
			status.appendText( "last RFID: " + lastRFID + "\n" );
			
			
			if (currentRFID.length>=6) {
				status.backgroundColor = uint("0x"+lastRFID.substr(lastRFID.length-7));	
			} else {
				status.backgroundColor = 0xCCCCCC;
			}
		}
		
		private function numberFormat(number:*, maxDecimals:int = 2, forceDecimals:Boolean = false, siStyle:Boolean = false):String {
			//Number formatter helper function
			//This method from: http://snipplr.com/view.php?codeview&id=27081
			var i:int = 0;
			var inc:Number = Math.pow(10, maxDecimals);
			var str:String = String(Math.round(inc * Number(number))/inc);
		    	var hasSep:Boolean = str.indexOf(".") == -1, sep:int = hasSep ? str.length : str.indexOf(".");
		    	var ret:String = (hasSep && !forceDecimals ? "" : (siStyle ? "," : ".")) + str.substr(sep+1);
		    	if (forceDecimals) {
					for (var j:int = 0; j <= maxDecimals - (str.length - (hasSep ? sep-1 : sep)); j++) ret += "0";
				}
		    	while (i + 3 < (str.substr(0, 1) == "-" ? sep-1 : sep)) ret = (siStyle ? "." : ",") + str.substr(sep - (i += 3), 3) + ret;
		    	return str.substr(0, sep - i) + ret;
		}
		
	}	
}