package
{
	import flash.utils.Dictionary;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Roger Veldman
	 */
	public class GameState extends FlxState
	{
		[Embed(source = "green.png")]
		public static const Green:Class;
		
		[Embed(source = "red.png")]
		public static const Red:Class;
		
		[Embed(source = "gray.png")]
		public static const Gray:Class;
		
		[Embed(source = "back.png")]
		public static const Back:Class;
		
		private var tiles:FlxGroup;
		
		private var turn:Boolean;
		
		private var goRed:Boolean;
		
		private var board:Dictionary;
		
		public function GameState()
		{
			board = new Dictionary();
			tiles = new FlxGroup();
			var back:FlxSprite = new FlxSprite(0, 0, Back);
			back.scrollFactor.x = back.scrollFactor.y = 0;
			//add(back);
			for (var i:int = 0; i < 4; i++)
			{
				for (var j:int = 0; j < 4; j++)
				{
					var tile:Tile = new Tile(16 + 32 * i, 16 + 32 * j);
					tile.loadGraphic(Gray);
					tile.locX = i + 1;
					tile.locY = j + 1;
					tiles.add(tile);
				}
			}
			add(tiles);
			turn = true;
			goRed = false;
			var text:FlxText = new FlxText(16, -1, 300, "Koopa Checkers");
			text.color = 0x40b031;
			text.shadow = 0x333333;
			add(text);
		
		}
		
		public override function update():void
		{
			
			if (turn && FlxG.mouse.justReleased())
			{
				var point:FlxSprite = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
				point.makeGraphic(1, 1, 0xFF0000);
				for each (var tile:Tile in tiles.members)
				{
					if (FlxG.overlap(point, tile))
					{
						tile.loadGraphic(Green);
						turn = false;
						board[tile.locX + " " + tile.locY] = "green";
					}
				}
				point.destroy();
			}
			
			if (!turn && !goRed)
			{
				var timer:FlxTimer = new FlxTimer();
				timer.start(.5, 1, setRed)
			}
			
			if (goRed)
			{
				var moveX:int = Math.ceil(Math.random() * 3);
				var moveY:int = 3;
				var point2:FlxSprite = new FlxSprite(moveX * 32 - 16, moveY * 32 - 16);
				point2.makeGraphic(1, 1, 0xFF0000);
				for each (var tile2:Tile in tiles.members)
				{
					if (FlxG.overlap(point2, tile2))
					{
						tile2.loadGraphic(Red);
						board[tile2.locX + " " + tile2.locY] = "red";
					}
				}
				turn = true;
				goRed = false;
				FlxG.log("red");
			}
			
			super.update();
		}
		
		private function setRed(num:int):void
		{
			if (!turn)
			{
				goRed = true;
			}
		}
	
	}

}