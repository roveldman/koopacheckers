package
{
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
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
		
		[Embed(source = "bullet.png")]
		public static const Bullet:Class;
		
		[Embed(source = "shell.mp3")]
		public static const Shell:Class;
		
		[Embed(source = "thwomp.mp3")]
		public static const Thwomp:Class;
		
		private var tiles:FlxGroup;
		
		private var turn:Boolean;
		
		private var goRed:Boolean;
		
		private var goBrowser:Boolean;
		
		private var board:Dictionary;
		
		private var size:int = 5;
		
		private var activeText:FlxText;
		
		private var timer:FlxTimer;
		
		private var koopatime:Number = .8;
		
		private var bowsertime:Number = 1;
		
		private var bullet:FlxSprite;
		
		private var winner:String;
		
		public function GameState()
		{
			bullet = new FlxSprite(-32, 32);
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
			var text:FlxText = new FlxText(0, -1, FlxG.width, "koopa checkers");
			text.alignment = "center"
			text.shadow = 0x333333;
			add(text);
			activeText = new FlxText(0, FlxG.height - 14, FlxG.width, "p");
			activeText.alignment = "center"
			
			add(activeText);
			bullet.loadGraphic(Bullet);
			add(bullet);
			winner = null;
			add(new FlxButton(-5,-5, "new", FlxG.resetState).makeGraphic(40,16))
		}
		
		public override function update():void
		{
			Mouse.show();
			
			if (winner != null)
			{
				activeText.shadow = 0x333333
				if (winner == "red")
				{
					activeText.text = "koopa wins!"
					activeText.color = 0xFFFF44;
				}
				if (hasWon() == "green")
				{
					activeText.text = "mario wins!"
					activeText.color = 0xFF4444;
					
				}
				super.update();
				return;
			}
			
			//FlxG.log(timer.timeLeft)
			if (turn && FlxG.mouse.justReleased())
			{
				var point:FlxSprite = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
				point.makeGraphic(1, 1, 0xFF0000);
				for each (var tile:Tile in tiles.members)
				{
					if (FlxG.overlap(point, tile) && board[tile.locX + " " + tile.locY] == null)
					{
						tile.loadGraphic(Green);
						turn = false;
						goRed = false;
						board[tile.locX + " " + tile.locY] = "green";
						FlxG.play(Shell);
						FlxG.shake(.005, .1);
						tile.angularVelocity = 800
						tile.angularDrag = 300;
						winner = hasWon()
					}
				}
				point.destroy();
			}
			
			if (!turn && !goRed && !goBrowser)
			{
				if (timer.loopsLeft == 0)
				{
					timer = new FlxTimer();
					koopatime = Math.random() / 2 + .5
					timer.start(koopatime, 1, setRed)
				}
			}
			
			if (goRed && !turn && !goBrowser && bullet.velocity.x == 0)
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
						FlxG.play(Shell);
						FlxG.shake(.005, .1);
						tile2.angularVelocity = -800
						tile2.angularDrag = 300;
						FlxG.log(scoreRowsCols(board));
						winner = hasWon();
					}
				}
				turn = false;
				goRed = false;
				timer.start(bowsertime, 1, setBrowser);
			}
			
			if (goBrowser)
			{
				goBrowser = false;
				goRed = false;
				if (Math.random() < .4 || countKeys(board) > .75 * (size * size))
				{
					if (Math.random() < .5)
					{
						bullet.x = -16;
						bullet.velocity.x = 200
					}
					else
					{
						bullet.x = FlxG.width + 32
						bullet.velocity.x = -200
					}
					
					// TODO fix this
					bullet.y = 16 + 32 * Math.round(Math.random() * (size - 1));
					FlxG.play(Thwomp);
					FlxG.shake(.01, .2);
					
				}
				else
				{
					turn = true;
				}
			}
			
			if (timer.loopsLeft == 0)
			{
				activeText.color = 0xFF4444;
				
				activeText.text = "mario's turn!"
			}
			else if (timer.time == koopatime)
			{
				if (!turn)
				{
					activeText.color = 0xFFFF44;
					activeText.text = "koopa is thinking"
				}
			}
			
			if (bullet.velocity.x != 0)
			{
				activeText.color = 0x44FF44
				activeText.text = "get rekt by bowser"
			}
			
			if (bullet.velocity.x != 0 && (bullet.x > FlxG.width + 33 || bullet.x < -33) && !turn)
			{
				turn = true;
				
				bullet.velocity.x = 0;
				bullet.x = -100;
				FlxG.log(scoreRowsCols(board));
				
			}
			
			for each (var til:Tile in tiles.members)
			{
				if (FlxG.overlap(til, bullet))
				{
					til.loadGraphic(Gray);
					delete board[til.locX + " " + til.locY];
				}
			}
			
			super.update();
		}
		
		private function setRed(num:int):void
		{
			if (!turn && !goBrowser)
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
						var score:Number = scoreRowsCols(newB);
						
						if (score < bestScore)
						{
							bestMove = x + "" + y + " ";
							bestScore = score;
						}
					}
					
				}
			}
			//FlxG.log(bestMove);
			return bestMove;
		}
		
		private function hasWon():String
		{
			for (var y:int = 1; y <= size; y++)
			{
				var rowScore:Number = 0;
				var rowScoreOther:Number = 0;
				
				for (var x:int = 1; x <= size; x++)
				{
					if (board[x + " " + y] == "green")
					{
						rowScore += 1;
					}
					if (board[x + " " + y] == "red")
					{
						rowScoreOther += 1;
					}
				}
				
				if (rowScore == size)
				{
					return "green";
				}
				if (rowScoreOther == size)
				{
					return "red";
				}
			}
			
			for (var a:int = 1; a <= size; a++)
			{
				var rowScore2:Number = 0;
				var rowScoreOther2:Number = 0;
				
				for (var b:int = 1; b <= size; b++)
				{
					if (board[a + " " + b] == "green")
					{
						rowScore2 += 1;
					}
					if (board[a + " " + b] == "red")
					{
						rowScoreOther2 += 1;
					}
				}
				
				if (rowScore2 == size)
				{
					return "green";
				}
				if (rowScoreOther2 == size)
				{
					return "red";
				}
			}
			return null;
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
						rowScore += 1;
					}
					
					if (b[x + " " + y] == "red")
					{
						rowScoreOther += 1;
					}
				}
				
				if (rowScoreOther > 0 && rowScore > 0)
				{
					
				}
				else
				{
					
					allRowsColsScore += Math.pow(rowScore, 2.5);
					allRowsColsScoreOther += Math.pow(rowScoreOther, 2.5);
				}
			}
			
			for (var i:int = 1; i <= size; i++)
			{
				var colScore:Number = 0;
				var colScoreOther:Number = 0;
				
				for (var j:int = 1; j <= size; j++)
				{
					if (b[i + " " + j] == "green")
					{
						colScore += 1;
					}
					if (b[i + " " + j] == "red")
					{
						colScoreOther += 1;
					}
				}
				
				if (colScore > 0 && colScoreOther > 0)
				{
				}
				else
				{
					allRowsColsScore += Math.pow(colScore, 2.5);
					allRowsColsScoreOther += Math.pow(colScoreOther, 2.5);
				}
			}
			return allRowsColsScore - allRowsColsScoreOther;
		}
		
		public function countKeys(dict:Dictionary):int
		{
			var n:int = 0;
			for (var key:* in dict)
			{
				n++;
			}
			return n;
		}
	}

}