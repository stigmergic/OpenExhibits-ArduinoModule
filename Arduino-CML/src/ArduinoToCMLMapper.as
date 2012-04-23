package {
	import com.gestureworks.cml.components.PanoramicViewer;
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.utils.LinkedMap;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	public class ArduinoToCMLMapper extends Sprite
	{
		private var button:Sprite;
		private var buttonLabel:TextField;
		private var buttonState:Boolean;
		
		private var panel:Sprite;

		private var _viewer:ArduinoViewer;
		
		
		
		
		public function ArduinoToCMLMapper(viewer:ArduinoViewer) {
			_viewer = viewer;
			
			var mappers:Array = [ 
				new DigitalMapper(2, 'tc1', 'visible', true),
				new DigitalMapper(2, 'tc2', 'visible', false),
				new AnalogMapper(2, 'tc3', 'x', 0, 1, 0, 750),
				new AnalogMapper(2, 'tc4', 'y', 0, 1, 750, 0),
				new RFIDMapper("", 'aspens', 'visible', true)
				];
			
			for each (var mapper:Mapper in mappers) {
				mapper.register(_viewer);
			}
						
			initButton();
			initPanel();
			
			addChild(button);
			addChild(panel);
			
			updateButton();
		}

		private function initPanel():void {
			panel = new Sprite();
			panel.y = 20;
			panel.visible = true;
			
			var box:TextField = new TextField();
			box.text = "TESTING\nTESTING\n";
			box.autoSize = "left";
			box.border = false;
			box.multiline = true;

			box.width = 250;
			
			box.background = true;
			box.backgroundColor = 0xCCCCCC;
			
			panel.addChild(box);
		}
		
		private function initButton(buttonState:Boolean=false):void {
			this.buttonState = buttonState;
			button = new Sprite();
			
			buttonLabel = new TextField();
			buttonLabel.background = true;
			buttonLabel.selectable = false;
			buttonLabel.height = 20;
			
			button.addChild(buttonLabel);
			
			button.x = 0; //1024 - button.width;
			button.y = 0;
			button.height = 20;
			
			button.addEventListener(MouseEvent.CLICK, toggleHandler);
			
			
		}
		
		private function updateButton():void {
			buttonLabel.text = buttonState ? "YES" : "NO";
			buttonLabel.textColor = 0xFFFFFF;
			buttonLabel.backgroundColor = buttonState ? 0x00CC00 : 0xCC0000;
			
			panel.visible = buttonState;
			if (buttonState) {
			}
			
			updateTouchContainers();
		}
		
		public function updateTouchContainers():void {
			var textField:TextField = TextField(panel.getChildAt(0));
			textField.text = "This: " + this.parent + "\n";
			
			//textField.appendText("aspens: " + CMLObjectList.instance.getId("aspens") + "\n");

			for  (var i:Number=0; i < CMLObjectList.instance.length; i++) {
				var result:Object = CMLObjectList.instance.getIndex(i);
				//var className:String = flash.utils.getQualifiedClassName( result );
				//var objectClass:Class = flash.utils.getDefinitionByName( className ) as Class;
				
				var tc:TouchContainer = result as TouchContainer;
				if (tc) {
					textField.appendText("id: " + tc.id + "\n");
					if (tc.id == 'aspens') {
						//tc.scale = (parent as Main).viewer.scale;
						//tc.visible = ((parent as Main).viewer.lastRFID === "4C0020A9B1"); 
					} else {
						tc.alpha = (parent as Main).viewer.scale;
					}
				}
			}
			
		}
		
		private function toggleHandler(event:Event):void {
			buttonState = !buttonState;
			updateButton();
			
			trace("Button: " + buttonLabel.text);			
		}

	}
}
