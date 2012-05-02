package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	
	

	public class LabeledInput extends Sprite
	{
		public var label:TextField;
		public var input:TextField;
		
		public function LabeledInput(label_text:String, input_text:String, label_width:int=40, input_width:int=40)
		{
			label = new TextField();
			label.background = true;
			label.backgroundColor = 0x222222;
			label.textColor = 0xCCCCCC;
			label.text = label_text;
			label.width = label_width;
			label.height = 15;
			label.selectable = false;
			addChild(label);
			
			input = new TextField();
			input.background = true;
			input.backgroundColor = 0x999900;
			input.textColor = 0x0000CC;
			input.text = input_text;
			input.width = input_width;
			input.height = 15;
			input.type = TextFieldType.INPUT;
			
			addChild(input);
			
			input.x += label.width;
			input.y = label.y;
		}
		
	}
}