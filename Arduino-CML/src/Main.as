package 
{
	import ArduinoViewer;
	
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.components.CMLDisplay;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

 CMLDisplay;
	
	[SWF(width = "1024", height = "768", backgroundColor = "0x000000", frameRate = "60")]
	
	public class Main extends GestureWorks
	{
		private var _viewer:ArduinoViewer;
		private var _mapper:ArduinoToCMLMapper;
		
		private var _globalListeners : Dictionary;
		
		public function Main():void 
		{
			super();
			settingsPath = "library/cml/my_application.cml";
			
			_globalListeners = new Dictionary();
			
			viewer = new ArduinoViewer();
			addChild(viewer);
			
			mapper = new ArduinoToCMLMapper(viewer);
			mapper.x = 200;
			addChild(mapper);
			
			addListenerForAllEvents( function(event:Event):void { trace(event); } );	
		}
		
		public function get mapper():ArduinoToCMLMapper
		{
			return _mapper;
		}

		public function set mapper(value:ArduinoToCMLMapper):void
		{
			_mapper = value;
		}

		public function get viewer():ArduinoViewer
		{
			return _viewer;
		}

		public function set viewer(value:ArduinoViewer):void
		{
			_viewer = value;
		}

		public function addListenerForAllEvents( listener : Function ) : void{
			_globalListeners[ listener ] = listener;
		}
		
		public function removeListenerForAllEvents( listener : Function ) : void{
			delete _globalListeners[ listener ];
		}
		
		override public function dispatchEvent(event:Event):Boolean{
			var result:Boolean = super.dispatchEvent( event );
			
			for each( var listener : Function in _globalListeners ){
				listener( event );
			}
			
			return result;
		}	
	}
	
}

