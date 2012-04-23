package
{
	public interface Mapper
	{
		function fire(id:Object, value:Number):void;
		
		function register(_viewer:ArduinoViewer):void;
		
		function unregister():void;
	}
}