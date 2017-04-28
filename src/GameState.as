package
{
	import flash.ui.Mouse;
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
		
		private var goBrowser:Boolean;
		
		private var board:Dictionary;
		
		private var size:int = 5;
		
		private var activeText:FlxText;
		
		private var timer:FlxTimer;
		
		private var koopatime:Number = .5;
		private var bowsertime:Number = .6;
		
		public function GameState()
		{
			timer = new FlxTimer();
			board = new Dictionary();
			tiles = new FlxGroup();
			var back:FlxSprite = new FlxSprite(0, 0, Back);
			back.scrollFactor.x = back.scrollFactor.y = 0;
			add(back);
			for (var i:int = 0; i < size; i++)
			{
				for (var j:int = 0; j < size; j++)
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
			goBrowser = false;
			var text:FlxText = new FlxText(50, -1, 300, "koopa checkers");
			text.color = 0x40b031;
			text.shadow = 0x333333;
			add(text);
			activeText = new FlxText(0, FlxG.height - 16, 100, "p");
			activeText.shadow = 0x333333;
			add(activeText);
		}
		
		public override function update():void
		{
			Mouse.show();
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
				if (timer.loopsLeft == 0)
				{
					timer.start(koopatime, 1, setRed)
					FlxG.log("red timer started");
				}
			}
			
			if (goRed && !turn && !goBrowser)
			{
				var move:String = greedy(board, 1, "red");
				var moveX:int = new Number(move.charAt(0));
				var moveY:int = new Number(move.charAt(1));
				
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
				turn = false;
				goRed = false;
				timer.start(bowsertime, 1, setBrowser);
			}
			
			if (goBrowser)
			{
				turn = true;
				goBrowser = false;
			}
			
			if (timer.loopsLeft == 0)
			{
				activeText.text = "me"
			}
			else if (timer.time == koopatime)
			{
				if (!turn)
				{
					activeText.text = "koopa"
				}
			}
			else if (timer.time == bowsertime)
			{
				activeText.text = "bowser"
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
		
		private function setBrowser(num:int):void
		{
			if (!turn && !goRed)
			{
				goBrowser = true;
			}
		}
		
		private function greedy(b:Dictionary, depth:int, color:String):String
		{
			var bestScore:int = int.MAX_VALUE;
			var bestMove:String;
			for (var y:int = 1; y <= size; y++)
			{
				for (var x:int = 1; x <= size; x++)
				{
					
					var newB:Dictionary = new Dictionary();
					
					for (var key:Object in b)
					{
						newB[key] = b[key]
					}
					
					if (newB[x + " " + y] == null)
					{
						
						newB[x + " " + y] = color;
						var score = scoreRowsCols(newB);
						
						if (score < bestScore)
						{
							bestMove = x + "" + y + " ";
							bestScore = score;
						}
							//FlxG.log(score + " " + x + "," + y);
					}
					
				}
			}
			
			//FlxG.log(bestMove);
			return bestMove;
		}
		
		private function scoreRowsCols(b:Dictionary):Number
		{
			var allRowsColsScore:Number = 0;
			var allRowsColsScoreOther:Number = 0;
			for (var y:int = 1; y <= size; y++)
			{
				var rowScore:Number = 0;
				var rowScoreOther:Number = 0;
				
				for (var x:int = 1; x <= size; x++)
				{
					if (b[x + " " + y] == "green")
					{
						rowScoreOther = 0
						rowScore += 1;
					}
					
					if (b[x + " " + y] == "red")
					{
						rowScore = 0
						rowScoreOther += 1;
					}
					
				}
				allRowsColsScore += Math.pow(rowScore, 2.5);
				allRowsColsScoreOther += Math.pow(rowScoreOther, 2.5);
			}
			
			for (var i:int = 1; i <= size; i++)
			{
				var colScore:Number = 0;
				var colScoreOther:Number = 0;
				
				for (var j:int = 1; j <= size; j++)
				{
					if (b[i + " " + j] == "green")
					{
						colScoreOther = 0;
						colScore += 1;
					}
					if (b[i + " " + j] == "red")
					{
						colScore = 0
						colScoreOther += 1;
					}
				}
				allRowsColsScore += Math.pow(colScore, 2.5);
				allRowsColsScoreOther += Math.pow(colScoreOther, 2.5);
			}
			return allRowsColsScore - allRowsColsScoreOther;
		}
	
	}

}