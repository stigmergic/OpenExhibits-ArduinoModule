package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
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
		
		private static var typeID:int=0;
		private var myTypeID:int;
		
		private var inputSectionWidth:int = 450;
		
		private var inactiveColor:uint = 0xBB0000;
		private var activeColor:uint = 0x00BB00;
		
		
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
			inMin = new LabeledInput(" Min", "0", 30, 25);
			inMax = new LabeledInput(" Max", "1", 30, 25);
						
			cmlId = new LabeledInput(" >> OUTPUT >> ObjectID", "Obj1", 85, 85);
			property = new LabeledInput(" Property", "Visible", 50, 85);

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
				inverse.backgroundColor = (inverse.backgroundColor == activeColor) ? inactiveColor : activeColor;				
			});
			
			
			outMin = new LabeledInput(" Min", "0", 30, 25);
			outMax = new LabeledInput(" Max", "1", 30, 25);
			
			typeID = (typeID>1) ? 0 : typeID + 1; 
			myTypeID = typeID;

			updateGUI();			
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
		
		private function setupDigital():void {
			removeChildren();
			type.text = " DIGITAL ";
			
			addChild(input_label);
			addAfter(input_label, type);
			addAfter(type, arduinoId);			

			addAfter(arduinoId, cmlId);
			cmlId.label.width =  inputSectionWidth - cmlId.x;
			cmlId.input.x = cmlId.label.width;

			addAfter(cmlId, property);
			addAfter(property, inverse);
			
		}

		private function rollChangeType(roll:int):Function {
			return function(event:MouseEvent):void {
				rollType(roll);
				updateGUI();
			}
		}
		
		private function setupAnalog():void {
			removeChildren();
			type.text = " ANALOG ";
			
			addChild(input_label);
			addAfter(input_label, type);
			addAfter(type, arduinoId);
			addAfter(arduinoId, inMin);
			addAfter(inMin, inMax);
			
			addAfter(inMax, cmlId);
			cmlId.label.width = inputSectionWidth - cmlId.x;
			cmlId.input.x = cmlId.label.width;
			
			addAfter(cmlId, property);
			addAfter(property, outMin);
			addAfter(outMin, outMax);
			
		}

		private function setupRFID():void {
			removeChildren();
			type.text = " RFID ";
			
			addChild(input_label);
			addAfter(input_label, type);
			addAfter(type, arduinoId);
			addAfter(arduinoId, rfid);
			
			addAfter(rfid, cmlId);
			cmlId.label.width = inputSectionWidth - cmlId.x;
			cmlId.input.x = cmlId.label.width;
			
			addAfter(cmlId, property);
			addAfter(property, inverse);
			
		}

		
		
		private function addAfter(first:*, second:*):void {
			addChild(second);
			second.x = first.x + first.width;
		}
		
		
		
	}
}