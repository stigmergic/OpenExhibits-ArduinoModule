package
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;

	public class RFIDMapper implements Mapper
	{
		private var rfid:String;
		private var cmlID:String;
		private var property:String;
		private var inverse:Boolean;
		
		private var _viewer:ArduinoViewer;
		
		public function RFIDMapper(rfid:String, cmlID:String, property:String, inverse:Boolean=false)
		{
			this.rfid = rfid;
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
			this._viewer.dispatcher.addRFIDEventListener(rfid, fire);
		}
		
		public function unregister():void {
			if (this._viewer != null) {
				this._viewer.dispatcher.addRFIDEventListener(rfid, fire);
			}
		}
		
		public function toString():String {
			return "RFID: " + rfid + " CML ID: " +  cmlID + " property: " + property + " inverse: " + inverse; 	
		}

		
	}	
}
