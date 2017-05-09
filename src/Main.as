package
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.ui.Mouse;
	import org.flixel.*;
	
	[SWF(width = "528", height = "528", backgroundColor = "#000000")]
	
	public class Main extends FlxGame
	{
		public static var scale:uint = 3;
		
		public function Main()
		{
			super(528 / scale, 528 / scale, LogoState, scale);
			
			forceDebugger = true;
			
			Mouse.show();
			
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
		
			useSoundHotKeys = false;
			
			DialogueManager.initDialogue();
			FlxG.stage.addChild(DialogueManager.backRect);
			FlxG.stage.addChild(DialogueManager.textView);
			FlxG.stage.addChild(DialogueManager.profile);
		}
	}
}