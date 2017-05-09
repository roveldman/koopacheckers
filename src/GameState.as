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
		[Embed(source = "res/green.png")]
		public static const Green:Class;
		
		[Embed(source = "res/red.png")]
		public static const Red:Class;
		
		[Embed(source = "res/gray.png")]
		public static const Gray:Class;
		
		[Embed(source = "res/back.png")]
		public static const Back:Class;
		
		[Embed(source = "res/bullet.png")]
		public static const Bullet:Class;
		
		[Embed(source = "res/shell.mp3")]
		public static const Shell:Class;
		
		[Embed(source = "res/thwomp.mp3")]
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
		
		private var lines:Array;
		
		private var tutorial:Number;
		
		private var newButton:FlxButton;
		
		private var moves:int;
		
		public function GameState()
		{
			moves = 0;
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
			newButton = new FlxButton(-5, -5, "new", FlxG.resetState);
			newButton.makeGraphic(40, 16)
			add(newButton)
			
			DialogueManager.show();
			DialogueManager.nextMessage("");
			lines = new Array();
			lines.push("Luigi: Hey there, bro!");
			/*lines.push("Luigi: Trying to make it big in koopa checkers I see?");
			lines.push("Luigi: Well, it's tough out here in the big leagues.");
			lines.push("Bowser Jr: I'll squash you.");
			lines.push("Luigi: Don't mind him.");
			lines.push("Bowser Jr: Blah watch out, overalls.");
			lines.push("Luigi: ... Wah-oo, kids these days sure crack me up.");
			lines.push("Luigi: So, the object of the game is to get five koopa shells in a row.");
			lines.push("Luigi: NOOO diagonals.");*/
			lines.push("Luigi: Just pick a koopa shell, any shell.");
			lines.push("end");
			
			refreshDialogue();
			
			tutorial = 0;
		}
		
		public override function update():void
		{
			if (tutorial != -1)
			{
				newButton.label.alpha = 0
				newButton.alpha = 0
				newButton.active = false
			}
			else
			{
				newButton.label.alpha = 1
				newButton.alpha = 1
				newButton.active = true
			}
			Mouse.show();
			
			if (tutorial == 6 && getBulletSpeed() == 0){
				tutorial = 7;
				lines.push("Luigi: Oh, boy. Guess you got to put up with that now.");
				lines.push("end");
				DialogueManager.show();
				refreshDialogue();
			}
			
			if (DialogueManager.profile.alpha != 0)
			{
				activeText.alpha = 0;
				super.update();
				if (FlxG.mouse.justReleased())
				{
					if (DialogueManager.isComplete())
					{
						refreshDialogue();
					}
					else
					{
						DialogueManager.finishText();
					}
				}
				return;
			}
			activeText.alpha = 1;
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
			
			
			if (moves > 7 && tutorial == 3)
			{
				tutorial = 5
				lines.push("Bowser Jr: Blahahahh. Time to turn up the heat, plumber!");
				lines.push("Bowser Jr: DAAAAAAAAAAAAADDDYYYY!");
				lines.push("Dad Bowser: Sup hotshot. ");
				lines.push("Bowser Jr: You're not in the frame.");
				lines.push("Eye Bowser: How's this?");
				lines.push("Bowser Jr: Better. Hey, Luigi's not letting me win and its NOT fair.");
				lines.push("Dad Bowser: What???");
				lines.push("Luigi: It's only been 8 turns, it's not even POSSIBLE for someone to have won yet!");
				lines.push("Dad Bowser: Are these runts giving you trouble? You know how ANGRY I get about my kid losing at match-3 clones.");
				lines.push("Bowser Jr: They're not letting me win!");
				lines.push("Luigi: N-n-n-o. (Mario, you might want to lose on purpose)");
				lines.push("Dad Bowser: No need for that!");
				
				lines.push("end");
				DialogueManager.show();
				refreshDialogue();
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
						moves++;
						FlxG.log(moves);
						tile.angularVelocity = 800
						tile.angularDrag = 300;
						winner = hasWon()
						if (tutorial == 0)
						{
							tutorial = 1;
						}
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
			
			if (goRed && !turn && !goBrowser && getBulletSpeed() == 0)
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
						moves++;
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
				
				if (tutorial == 2)
				{
					tutorial = 3;
					lines.push("Luigi: All of Tiny's will be red.");
					lines.push("Bowser Jr: Wahaha. Don't call me that.");
					lines.push("Luigi: Hey, at least they don't call you \"Green Mario\".");
					lines.push("Luigi: Your turn, Mario.");
					lines.push("end");
					DialogueManager.show();
					refreshDialogue();
				}
				
				if (tutorial == 5){
					doBowser();
					tutorial = 6;
				}
				if ((Math.random() < .3 || countKeys(board) > .75 * (size * size)) && tutorial==-1)
				{
					doBowser();
					
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
					activeText.text = "bowser jr. is thinking"
					for (var i:int = 0; i < 3 - Math.round(timer.timeLeft / timer.time * 3); i++)
					{
						activeText.text = activeText.text + "."
					}
				}
				
			}
			
			if (getBulletSpeed() != 0)
			{
				activeText.color = 0x44FF44
				activeText.text = "get rekt by bowser"
			}
			
			if (getBulletSpeed() != 0 && (bullet.x > FlxG.width + 33 || bullet.x < -33 || bullet.y < -33 || bullet.y > FlxG.height + 33) && !turn)
			{
				turn = true;
				
				bullet.velocity.x = 0;
				bullet.velocity.y = 0;
				bullet.x = -100;
				bullet.y = -100
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
			if (tutorial == 1)
			{
				tutorial = 2;
				lines.push("Luigi: Alright! All your koopa shells will be green.");
				lines.push("Bowser Jr: Mwahahaha. My turn!");
				lines.push("end");
				DialogueManager.show()
				refreshDialogue();
				return;
			}
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
		
		private function doBowser():void 
		{
			var rand:Number = Math.random();
			if (rand < .25)
			{
				bullet.x = -16;
				bullet.velocity.x = 200
				bullet.y = 16 + 32 * Math.round(Math.random() * (size - 1));
				
			}
			else if (rand < .5)
			{
				
				bullet.x = FlxG.width + 32
				bullet.velocity.x = -200
				bullet.y = 16 + 32 * Math.round(Math.random() * (size - 1));
				
			}
			else if (rand < .75)
			{
				bullet.y = FlxG.height
				bullet.velocity.y = -200
				bullet.x = 16 + 32 * Math.round(Math.random() * (size - 1));
				FlxG.log("ok")
				
			}
			else
			{
				bullet.y = -16
				bullet.velocity.y = 200
				bullet.x = 16 + 32 * Math.round(Math.random() * (size - 1));
				
			}
			
			FlxG.play(Thwomp);
			FlxG.shake(.01, .2);
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
		
		public function getBulletSpeed():Number
		{
			return Math.sqrt(Math.pow(Math.abs(bullet.velocity.x), 2) + Math.pow(Math.abs(bullet.velocity.y), 2));
		}
		
		public function refreshDialogue():void
		{
			DialogueManager.nextMessage(lines.shift());
			FlxG.stage.addChild(DialogueManager.profile);
		}
	}

}