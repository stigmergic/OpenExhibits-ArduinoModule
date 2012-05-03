package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class MapperUI extends Sprite
	{
		private var _mapper:Mapper;
		private var _viewer:ArduinoViewer;
	

		private var input_label:TextField;
		private var arduinoId:LabeledInput;		
		private var type:TextField;
		private var inMin:LabeledInput;
		private var inMax:LabeledInput;
		private var rfid:LabeledInput;
		
		private var cmlId:LabeledInput;
		private var property:LabeledInput;
		private var inverse:TextField;
		private var outMin:LabeledInput;
		private var outMax:LabeledInput;
		
		private var sep1:TextField;
		private var sep2:TextField;
		
		private static var typeID:int=0;
		private var myTypeID:int;
		
		private var inputSectionWidth:int = 300;
		private var totalWidth:int = 800;
		
		private var inactiveColor:uint = 0xBB0000;
		private var activeColor:uint = 0x00BB00;
		
		private var _analogMapper:AnalogMapper;
		private var _digitalMapper:DigitalMapper;
		private var _rfidMapper:RFIDMapper;
		
		private var minusButton:TextField;
		
		public function MapperUI(viewer:ArduinoViewer)
		{
			_viewer = viewer;
			
			input_label = new TextField();
			input_label.text = " INPUT ";
			input_label.background = true;
			input_label.backgroundColor = inactiveColor;
			input_label.textColor = 0xFFFFFF;
			input_label.width = 45;
			input_label.height = 15;
			input_label.selectable = false;
			
			input_label.addEventListener(MouseEvent.CLICK, rollChangeType(1));
			
			type = new TextField();
			type.text = " UNKNOWN ";
			type.background = true;
			type.backgroundColor = 0xC000C0;
			type.textColor = 0xFFFFFF;
			type.width = 60;
			type.height = 15;
			type.selectable = false;
			type.addEventListener(MouseEvent.CLICK, rollChangeType(-1));
			
						
			arduinoId = new LabeledInput(" Pin #", "0", 35, 20);

			rfid = new LabeledInput(" RFID", "4C0020D927", 35, 70);
			inMin = new LabeledInput(" Min", "0", 30, 35);
			inMax = new LabeledInput(" Max", "1", 30, 35);
						
			sep1 = new TextField();
			sep1.background = true;
			sep1.backgroundColor = 0x222222;
			sep1.textColor = 0xCCCCCC;
			sep1.text = "";
			sep1.width = 10;
			sep1.height = 15;
			sep1.selectable = false;

			cmlId = new LabeledInput(" >> map to >> CML ObjID", "Obj1", 140, 85);
			//cmlId.label.autoSize = TextFieldAutoSize.CENTER;

			property = new LabeledInput(" Property", "visible", 50, 85);

			inverse = new TextField()
			inverse.text = " Inverse ";
			inverse.background = true;
			inverse.backgroundColor = inactiveColor;
			inverse.textColor = 0xFFFFFF;
			inverse.selectable = false;
			inverse.height = 15;
			inverse.width = 45;
			inverse.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
				var inverse:TextField = event.target as TextField;
				inverse.backgroundColor = (isInverse()) ? inactiveColor : activeColor;	
				updateListener();
			});
			
			
			outMin = new LabeledInput(" Min", "0", 30, 35);
			outMax = new LabeledInput(" Max", "1", 30, 35);

			sep2 = new TextField();
			sep2.background = true;
			sep2.backgroundColor = 0x222222;
			sep2.textColor = 0xCCCCCC;
			sep2.text = "";
			sep2.width = 10;
			sep2.height = 15;
			sep2.selectable = false;
			
			minusButton = new TextField();
			minusButton.background = true;
			minusButton.backgroundColor = 0x222222;
			minusButton.textColor = 0xFFFFFF;
			minusButton.text = " - ";
			minusButton.width = 10;
			minusButton.height = 15;
			minusButton.selectable = false;
			minusButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				var ui:Sprite = event.target.parent.parent;
				ui.removeChild(event.target.parent);				
				clearMappers();
				var lastY:int = 0;
				for (var i:int=0; i<ui.numChildren; i++) {
					ui.getChildAt(i).y = i * 15;
				}
			});
			

			this.addEventListener(Event.CHANGE, updateEventListener);
			
			typeID = (typeID>1) ? 0 : typeID + 1; 
			myTypeID = typeID;

			updateGUI();			
			updateListener();
		}
		
		public function clearMappers():void {
			if (_digitalMapper != null) {_digitalMapper.unregister(); _digitalMapper = null; }
			if (_analogMapper != null) {_analogMapper.unregister(); _analogMapper = null; }
			if (_rfidMapper != null) {_rfidMapper.unregister(); _rfidMapper = null; }
		}
		
		public function setToMapper(mapper:Mapper):void {
			clearMappers();
			if (mapper is DigitalMapper) {
				_digitalMapper = mapper as DigitalMapper;
				myTypeID = 0;
				arduinoId.input.text = _digitalMapper.pin.toString();
				cmlId.input.text = _digitalMapper.cmlID;
				property.input.text = _digitalMapper.property;
				setInverse(_digitalMapper.inverse);
				
			} else if  (mapper is AnalogMapper) {
				_analogMapper = mapper as AnalogMapper;
				myTypeID = 1;
				arduinoId.input.text = _analogMapper.pin.toString();
				cmlId.input.text = _analogMapper.cmlID;
				property.input.text = _analogMapper.property;
				inMin.input.text = _analogMapper.inMin.toString();
				inMax.input.text = _analogMapper.inMax.toString();
				outMin.input.text = _analogMapper.outMin.toString();
				outMax.input.text = _analogMapper.outMax.toString();
				
			} else if  (mapper is RFIDMapper) {
				_rfidMapper = mapper as RFIDMapper;
				myTypeID = 2;
				rfid.input.text = _rfidMapper.rfid;
				cmlId.input.text = _rfidMapper.cmlID;
				property.input.text = _rfidMapper.property;
				setInverse(_rfidMapper.inverse);
				
			}
			updateGUI();
			updateListener();
		}

		public function updateListener():void {
			clearMappers();	
			if (myTypeID == 0) updateDigitalMapper();
			if (myTypeID == 1) updateAnalogMapper();
			if (myTypeID == 2) updateRFIDMapper();			
		}
		
		public function updateEventListener(event:Event):void {
			trace("got event: " + event);
			updateListener();			
		}
		
		public function isInverse():Boolean {
			return inverse.backgroundColor == activeColor;			
		}
		
		public function setInverse(value:Boolean):void {
			inverse.backgroundColor = (value) ? activeColor : inactiveColor;				
		}

		public function getRFID():String {
			return rfid.input.text;			
		}

		public function getCMLID():String {
			return  cmlId.input.text;			
		}

		public function getProperty():String {
			return  property.input.text;			
		}
		
		public function getPin():Number {
			return parseInt(arduinoId.input.text);			
		}

		public function getInMin():Number {
			return parseFloat(inMin.input.text);			
		}
		public function getInMax():Number {
			return parseFloat(inMax.input.text);			
		}
		public function getOutMin():Number {
			return parseFloat(outMin.input.text);			
		}
		public function getOutMax():Number {
			return parseFloat(outMax.input.text);			
		}



		public function updateRFIDMapper():RFIDMapper
		{
			if (_rfidMapper != null) {
				_rfidMapper.unregister();
			}
				
			_rfidMapper = new RFIDMapper(getRFID(), getCMLID(), getProperty(), isInverse());
			_rfidMapper.register(_viewer);
			
			return _rfidMapper;
		}

		
		public function get rfidMapper():RFIDMapper
		{
			return _rfidMapper;
		}

		public function set rfidMapper(value:RFIDMapper):void
		{
			if (_rfidMapper != null) {
				_rfidMapper.unregister();
			}

			_rfidMapper = value;
		}
		

		public function updateDigitalMapper():DigitalMapper
		{
			if (_digitalMapper != null) {
				_digitalMapper.unregister();
			}
			
			_digitalMapper = new DigitalMapper(getPin(), getCMLID(), getProperty(), isInverse());
			_digitalMapper.register(_viewer);
			
			return _digitalMapper;
		}

		
		public function get digitalMapper():DigitalMapper
		{
			return _digitalMapper;
		}

		public function set digitalMapper(value:DigitalMapper):void
		{
			if (_digitalMapper != null) {
				_digitalMapper.unregister();
			}

			_digitalMapper = value;
		}
		
		public function updateAnalogMapper():AnalogMapper
		{
			if (_analogMapper != null) {
				_analogMapper.unregister();
			}
			
			_analogMapper = new AnalogMapper(getPin(), getCMLID(), getProperty(), getInMin(), getInMax(), getOutMin(), getOutMax()); 
			_analogMapper.register(_viewer);
			
			return _analogMapper;
		}


		public function get analogMapper():AnalogMapper
		{
			return _analogMapper;
		}

		public function set analogMapper(value:AnalogMapper):void
		{
			if (_analogMapper != null) {
				_analogMapper.unregister();
			}
			_analogMapper = value;
		}

		private function updateGUI():void {
			if (myTypeID == 0) setupDigital();
			if (myTypeID == 1) setupAnalog();
			if (myTypeID == 2) setupRFID();
			
		}
		
		private function rollType(r:int=1):void {
			myTypeID += r;
			if (myTypeID < 0) myTypeID = 3 - ( (-myTypeID) % 3 );  
			if (myTypeID > 0) myTypeID %= 3;
		}

		private function rollChangeType(roll:int):Function {
			return function(event:MouseEvent):void {
				rollType(roll);
				updateGUI();
				updateListener();
			}
		}
		
		
		private function setupDigital():void {
			removeChildren();
			type.text = " DIGITAL ";
			
			addChild(input_label);
			addAfter(input_label, type);
			addAfter(type, arduinoId);			
			addAfter(arduinoId, sep1);
			sep1.width =  inputSectionWidth - sep1.x;
			addAfter(sep1, cmlId);

			addAfter(cmlId, property);
			addAfter(property, inverse);
			
			addAfter(inverse, sep2);
			sep2.width = totalWidth - sep2.x;
			addAfter(sep2, minusButton);
			
		}

		private function setupAnalog():void {
			removeChildren();
			type.text = " ANALOG ";
			
			addChild(input_label);
			addAfter(input_label, type);
			addAfter(type, arduinoId);
			addAfter(arduinoId, inMin);
			addAfter(inMin, inMax);
			
			addAfter(inMax, sep1);
			sep1.width =  inputSectionWidth - sep1.x;
			addAfter(sep1, cmlId);
			
			addAfter(cmlId, property);
			addAfter(property, outMin);
			addAfter(outMin, outMax);
			
			addAfter(outMax, sep2);
			sep2.width = totalWidth - sep2.x;
			addAfter(sep2, minusButton);

			
		}

		private function setupRFID():void {
			removeChildren();
			type.text = " RFID ";
			
			addChild(input_label);
			addAfter(input_label, type);
			addAfter(type, rfid);

			addAfter(rfid, sep1);
			sep1.width =  inputSectionWidth - sep1.x;
			addAfter(sep1, cmlId);
			
			addAfter(cmlId, property);
			addAfter(property, inverse);

			addAfter(inverse, sep2);
			sep2.width = totalWidth - sep2.x;
			addAfter(sep2, minusButton);
			
		}

		
		
		private function addAfter(first:*, second:*):void {
			addChild(second);
			second.x = first.x + first.width;
		}
		
		
		
	}
}