package
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;
	
	public class AnalogMapper implements Mapper
	{
		public var pin:Number;
		public var cmlID:String;
		public var property:String;
		public var inMin:Number;
		public var inMax:Number;
		public var outMin:Number;
		public var outMax:Number;
		
		private var _viewer:ArduinoViewer;
		
		public function AnalogMapper(pin:Number, cmlID:String, property:String, inMin:Number=0, inMax:Number=1.0, outMin:Number=0.0, outMax:Number=1.0)
		{
			this.pin = pin;
			this.cmlID = cmlID;
			this.property = property;
			this.inMin = inMin;
			this.inMax = inMax;
			this.outMin = outMin;
			this.outMax = outMax;
		}
		 
				
		public function fire(pin:Object, value:Number):void {		
			var obj:* = CMLObjectList.instance.getId(cmlID);
			
			var newValue:Number = value;
			if (Math.abs(this.inMax-this.inMin) < 0.00001) newValue=value;
			else newValue=(value - this.inMin)*(this.outMax-this.outMin)/(this.inMax-this.inMin) + this.outMin;
			
			if (obj && obj.hasOwnProperty(property)) {
				obj[property] = newValue;
			}
		}
		
		public function register(_viewer:ArduinoViewer):void
		{			
			this._viewer = _viewer;
			this._viewer.dispatcher.addAnalogEventListener(pin, fire);
			
			if (pin>=0) fire(pin, _viewer.analogPins[pin]);
		}
		
		public function unregister():void {
			if (this._viewer != null) {
				this._viewer.dispatcher.removeAnalogEventListener(pin, fire);
			}
		}
		
		public function toString():String {
			return "Analog pin: " + pin + " min: " + inMin + " max: " + inMax + " CML ID: " +  cmlID + " property: " + property + " min: " + outMin + " max: " + outMax; 	
		}
		
	}
}