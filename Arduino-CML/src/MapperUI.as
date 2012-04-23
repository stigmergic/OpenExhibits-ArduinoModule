package
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class MapperUI extends Sprite
	{
		private var _mapper:Mapper = null;
		private var _viewer:ArduinoViewer;
	
		private var type:String;
		private var arduinoId:TextField;
		private var cmlId:TextField;
		private var property:TextField;
		private var inverse:TextField;
		private var inMin:TextField;
		private var inMax:TextField;
		private var outMin:TextField;
		private var outMax:TextField;
		
		
		public function MapperUI(viewer:ArduinoViewer)
		{
			_viewer = viewer;
		}
		
		
	}
}