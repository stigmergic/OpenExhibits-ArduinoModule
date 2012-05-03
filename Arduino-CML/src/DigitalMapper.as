package
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;

	public class DigitalMapper implements Mapper
	{
		public var pin:Number;
		public var cmlID:String;
		public var property:String;
		public var inverse:Boolean;
		
		private var _viewer:ArduinoViewer;
		
		public function DigitalMapper(pin:Number, cmlID:String, property:String, inverse:Boolean=false)
		{
			this.pin = pin;
			this.cmlID = cmlID;
			this.property = property;
			this.inverse = inverse;
		}
				
		public function fire(pin:Object, value:Number):void {
			var obj:* = CMLObjectList.instance.getId(cmlID);
			if (obj && obj.hasOwnProperty(property)) {
				obj[property] = inverse ? !value : value;
			}
		}
		
		public function register(_viewer:ArduinoViewer):void
		{
			this._viewer = _viewer;
			this._viewer.dispatcher.addDigitalEventListener(pin, fire);
			
			fire(pin, _viewer.digitalPins[pin]);
		}
		
		public function unregister():void {
			if (this._viewer != null) {
				this._viewer.dispatcher.removeDigitalEventListener(pin, fire);
			}
		}
		
		public function toString():String {
			return "Digital Pin: " + pin + " CML ID: " +  cmlID + " property: " + property + " inverse: " + inverse; 	
		}

		
	}
}