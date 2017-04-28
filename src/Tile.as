package 
{
	import org.flixel.FlxSprite;
	
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
		
	}

}