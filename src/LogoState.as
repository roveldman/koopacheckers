package
{
	import org.flixel.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/**
	 * ...
	 * @author Roger Veldman
	 */
	public class LogoState extends FlxState
	{
		private var myTimer:Timer;
		
		[Embed(source = "res/poweron.mp3")]
		public static const PowerOn:Class;
		
		[Embed(source = "res/logo.png")]
		public static const Logo:Class;
		
		private var count:uint = 0;
		
		private var message:String;
		private var disclaimer:FlxText;

		
		public function LogoState()
		{
			super();
			message =  "All Mario characters are property of Nintendo\t";
			add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height));
			var snd:FlxSound = new FlxSound();
			snd.loadEmbedded(PowerOn);
			snd.volume = .5;
			var logo:FlxSprite = new FlxSprite(FlxG.width / 2, FlxG.height / 2, Logo);
			logo.x -= logo.width / 2;
			logo.y -= logo.height / 2;
			disclaimer = new FlxText(32, FlxG.height / 2 - 16, FlxG.width - 64, message);
			//disclaimer.alignment = "center"
			disclaimer.color = 0xffaf80;
			disclaimer.alpha = 0;
			add(disclaimer);
			myTimer = new Timer(650/2);
			myTimer.addEventListener(TimerEvent.TIMER, timerListener);
			function timerListener(e:TimerEvent):void
			{
				if (count >= 10)
				{
					logo.alpha = 0;
					disclaimer.alpha = 1;
				}
				if (count == 2)
				{
					add(logo);
					snd.play();
				}
				count++;
			}
			myTimer.start();
		}
		
		public override function update():void
		{
			if (FlxG.mouse.justReleased() && count > 5)
			{
				FlxG.switchState(new GameState);
				myTimer.stop();
			}
			if (count % 2 == 0){
				disclaimer.text = message;
			} else {
				disclaimer.text = message + "->"
			}
		}
	
	}

}