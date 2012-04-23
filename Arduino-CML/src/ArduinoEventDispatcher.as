package
{
	import flash.utils.Dictionary;
	
	public class ArduinoEventDispatcher 
	{

		//Dictionaries for Event listeners.
		private var _digitalListeners:Dictionary;
		private var _analogListeners:Dictionary;
		private var _rfidListeners:Dictionary;
		
		

		public function ArduinoEventDispatcher()
		{
			_digitalListeners = new Dictionary();
			_analogListeners = new Dictionary();
			_rfidListeners = new Dictionary();

		}
		
		public function addDigitalEventListener(pin:Number, listener:Function):void {
			if (_digitalListeners[pin] == null) {
				_digitalListeners[pin] = new Dictionary();
			}
			
			(_digitalListeners[pin] as Dictionary)[listener] = listener;
		}
		
		public function removeDigitalEventListener(pin:Number, listener:Function):void {
			var listeners:Dictionary = _digitalListeners[pin] as Dictionary;
			if (listeners != null) {
				delete listeners[listener];
			}
		}
		
		public function dispatchDigitalEvent(pin:Number, value:Number):void {
			var listeners:Dictionary = _digitalListeners[pin] as Dictionary;
			var listener:Function;
			
			if (listeners != null) {
				for each(listener in listeners) {
					listener(pin, value);
				}
			}
			listeners = _digitalListeners[-1] as Dictionary;
			if (listeners != null) {
				for each(listener in listeners) {
					listener(pin, value);
				}
			}

		}

		public function addAnalogEventListener(pin:Number, listener:Function):void {
			if (_analogListeners[pin] == null) {
				_analogListeners[pin] = new Dictionary();
			}
			
			(_analogListeners[pin] as Dictionary)[listener] = listener;
		}
		
		public function removeAnalogEventListener(pin:Number, listener:Function):void {
			var listeners:Dictionary = _analogListeners[pin] as Dictionary;
			if (listeners != null) {
				delete listeners[listener];
			}
		}
		
		public function dispatchAnalogEvent(pin:Number, value:Number):void {
			var listeners:Dictionary = _analogListeners[pin] as Dictionary;
			var listener:Function;
			
			if (listeners != null) {
				for each(listener in listeners) {
					listener(pin, value);
				}
			}
			listeners = _analogListeners[-1] as Dictionary;
			if (listeners != null) {
				for each(listener in listeners) {
					listener(pin, value);
				}
			}

		}

		public function addRFIDEventListener(rfid:String, listener:Function):void {
			if (_rfidListeners[rfid] == null) {
				_rfidListeners[rfid] = new Dictionary();
			}
			
			(_rfidListeners[rfid] as Dictionary)[listener] = listener;
		}
		
		public function removeRFIDEventListener(rfid:String, listener:Function):void {
			var listeners:Dictionary = _rfidListeners[rfid] as Dictionary;
			if (listeners != null) {
				delete listeners[listener];
			}
		}

		
		public function dispatchRFIDEvent(rfid:String, value:Number):void {
			var listeners:Dictionary = _rfidListeners[rfid] as Dictionary;
			var listener:Function;
			
			if (listeners != null) {
				for each(listener in listeners) {
					listener(rfid, value);
				}
			}
			listeners = _rfidListeners[""] as Dictionary;
			if (listeners != null) {
				for each(listener in listeners) {
					listener(rfid, value);
				}
			}

		}
		
		
	}
}