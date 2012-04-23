/** 
 * 
 *  April 13
 * 		Made the button creation/update/write/toggle into individual methods
 * 		Background color change on the button
 * 		Exception handling when lost connection with arduino -- Could be problem if arduino just loses power...
 * 		Reading the digital pin.  Unable to read analog so far. 
 *  April 16
 * 		Analog input is working
 * 		Re-worked how the data is read, now completely event based
 * 		Poteiometer (analog) reading is scaled between 0 and 1.0
 * 		Still need some work to get things going at the start (reset board required, sometimes twice)
 *  April 19		
 * 		RFID reading works
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
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
		
		private const firstDigitalPin:Number = 2;
		private const lastDigitalPin:Number = 49;
		
		private const RFID_RX:Number = 50;
		private const RFID_TX:Number = 51;
		private const RFID_RESET_PIN:Number = 52;
		private const RFID_RESET_TIME:Number = 200;
		private const RFID_CONTINOUS_TIMEOUT:Number = 500;
		
		private var rfid_continous_timer:Timer;

		private const firstAnalogPin:Number = 0;
		private const lastAnalogPin:Number = 15;//15;
		
		private var digitalPins:Array = new Array(lastDigitalPin+1);
		private var analogPins:Array = new Array(lastAnalogPin+1);
		
		private var currentRFID:String = ""; 
		public var lastRFID:String = ""; 
				
		private var _dispatcher:ArduinoEventDispatcher;		
		
		public function ArduinoViewer()
		{
			_dispatcher = new ArduinoEventDispatcher();
			
			_dispatcher.addDigitalEventListener(-1, function(pin:Number, value:Number):void { trace("Digital event for pin: " + pin + " value: " + value); });
			_dispatcher.addAnalogEventListener(-1, function(pin:Number, value:Number):void { /*trace("Analog event for pin: " + pin + " value: " + value); */ });
			_dispatcher.addRFIDEventListener("", function(rfid:String, value:Number):void { trace("RFID event for rfid: " + rfid + " value: " + value); });
			
			
			initArduino();
			
			
			status = new TextField();
			status.text = "waiting... Press reset button if this message doesn't change.";
			status.y = 20;
			status.height = 200;
			status.width = 180;
			status.autoSize = "left";
			
			var format:TextFormat = new TextFormat("fixed-width");
			
			status.setTextFormat(format);
			
			status.background = true;
			status.backgroundColor = 0xCCCCCC;
				
			addChild(createButton());
			addChild(status);
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
				arduino = new Arduino("127.0.0.1",5331);

				arduino.addEventListener(Event.CONNECT,onSocketConnect);
				arduino.addEventListener(Event.CLOSE,onSocketClose);
				arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, firmwareHandler);
				arduino.addEventListener(ArduinoSysExEvent.SYSEX_MESSAGE, sysexHandler);
			
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

			arduino.setPinMode(RFID_RX, Arduino.INPUT);
			arduino.setPinMode(RFID_TX, Arduino.OUTPUT);
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
			
			//trace("Digital Pin: " + pin + " val: " + value);
			
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

		private function writeRFIDResetPin(mode:int=Arduino.HIGH):void {
			try {
				arduino.writeDigitalPin(RFID_RESET_PIN, mode);
			} catch (e:Error) {
				trace('Error: ' + e + "\ntype: " + e.errorID + " " );
				initArduino();
				//possible endless loop here. writeButton is called from initArduino... 	
			}

		}
		
		private function frameHandler(event:Event):void {
			writeButton();
			updateButton();
												
			status.text = "";
			status.appendText( "Firmware: " + arduino.getFirmwareVersion() + "\n");
			status.appendText( "connected: " + arduino.connected + "\n" );
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