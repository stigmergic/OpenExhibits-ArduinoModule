package
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;
	
	public class AnalogMapper implements Mapper
	{
		private var pin:Number;
		private var cmlID:String;
		private var property:String;
		private var inMin:Number;
		private var inMax:Number;
		private var outMin:Number;
		private var outMax:Number;
		
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
			
			try {
				var obj:TouchContainer = CMLObjectList.instance.getId(cmlID) as TouchContainer;
				
				var newValue:Number = value;
				if (Math.abs(this.inMax-this.inMin) < 0.00001) newValue=value;
				else newValue=(value - this.inMin)*(this.outMax-this.outMin)/(this.inMax-this.inMin) + this.outMin;
				//trace("value: " + value + " newValue: " + newValue);
				
				obj[property] = newValue;
			} catch (e:Error) {
				trace(e);
			}
		}
		
		public function register(_viewer:ArduinoViewer):void
		{			
			this._viewer = _viewer;
			this._viewer.dispatcher.addAnalogEventListener(pin, fire);
		}
		
		public function unregister():void {
			if (this._viewer != null) {
				this._viewer.dispatcher.removeAnalogEventListener(pin, fire);
			}
		}
		
	}
}