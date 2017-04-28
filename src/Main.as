package
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.ui.Mouse;
	import org.flixel.*;
	
	[SWF(width = "448", height = "448", backgroundColor = "#000000")]
	
	public class Main extends FlxGame
	{
		
		public function Main()
		{
			var scale:uint = 4;
			super(448 / scale, 448 / scale, GameState, scale); 

			
			FlxG.bgColor = 0xffff55ff;
			forceDebugger = true;
			Mouse.show();
			
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			
			
			//useDefaultHotKeys = false;
		}
	}
}