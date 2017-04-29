package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Roger Veldman
	 */
	public class Tile extends FlxSprite 
	{
		public var locX:int;
		public var locY:int;
		public function Tile(X:Number=0, Y:Number=0, SimpleGraphic:Class=null) 
		{
			super(X, Y, SimpleGraphic);
			
		}
		
		public override function update():void{
			super.update();
			if (angularVelocity == 0 && angle%90!=0){
				angle = Math.round(angle / 90) * 90
			}
		}
		
	}

}