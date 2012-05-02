package {
	import com.gestureworks.cml.components.PanoramicViewer;
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.utils.LinkedMap;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import spark.components.Label;
	
	
	public class ArduinoToCMLMapper extends Sprite
	{
		private var button:Sprite;
		private var buttonLabel:TextField;
		private var buttonState:Boolean;
		
		private var panel:Sprite;

		private var mappers:Array;
		
		private var _viewer:ArduinoViewer;
				
		public function ArduinoToCMLMapper(viewer:ArduinoViewer) {
			_viewer = viewer;
			
			mappers = [ 
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
			buttonLabel.text = "Maps";
			buttonLabel.textColor = 0xFFFFFF;
			buttonLabel.backgroundColor = buttonState ? 0x00CC00 : 0xCC0000;
			
			panel.visible = buttonState;
			
			if (buttonState) {
				var box:TextField = panel.getChildAt(0) as TextField;
				box.text = "";
				for each (var mapper:Mapper in mappers) {
					box.appendText(mapper.toString() + "\n");
				}

			
				var mapperui:MapperUI = new MapperUI(_viewer);
				panel.addChild(mapperui);
								
				var predIndex:int = mapperui.parent.getChildIndex(mapperui) - 1;
				if (predIndex >= 0) {
					var pred:DisplayObject = mapperui.parent.getChildAt(predIndex);
					mapperui.y = pred.y + pred.height + 2;
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
