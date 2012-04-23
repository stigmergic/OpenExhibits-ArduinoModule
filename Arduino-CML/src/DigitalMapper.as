package
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;

	public class DigitalMapper implements Mapper
	{
		private var pin:Number;
		private var cmlID:String;
		private var property:String;
		private var inverse:Boolean;
		
		private var _viewer:ArduinoViewer;
		
		public function DigitalMapper(pin:Number, cmlID:String, property:String, inverse:Boolean=false)
		{
			this.pin = pin;
			this.cmlID = cmlID;
			this.property = property;
			this.inverse = inverse;
		}
				
		public function fire(pin:Object, value:Number):void {
			try {
				var obj:TouchContainer = CMLObjectList.instance.getId(cmlID) as TouchContainer;
				obj[property] = inverse ? !value : value;
			} catch (e:Error) {
				trace(e);
			}
		}
		
		public function register(_viewer:ArduinoViewer):void
		{
			this._viewer = _viewer;
			this._viewer.dispatcher.addDigitalEventListener(pin, fire);
		}
		
		public function unregister():void {
			if (this._viewer != null) {
				this._viewer.dispatcher.removeDigitalEventListener(pin, fire);
			}
		}
		
	}
}