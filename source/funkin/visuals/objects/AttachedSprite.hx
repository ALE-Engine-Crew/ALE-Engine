package visuals.objects;

class AttachedSprite extends FlxSprite
{
	public var sprTracker:Dynamic;

	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public var widthAdd:Float = 0;
	public var heightAdd:Float = 0;

	public var widthMultiplier:Float = 0;
	public var heightMultiplier:Float = 0;
	
	public var angleAdd:Float = 0;
	public var alphaMult:Float = 1;

	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;
	public var copySize:Bool = false;

	public function new(?sprite:FlxSprite = null)
	{
		super(x, y);

		sprTracker = sprite;

		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (visible == false || alpha == 0 || sprTracker == null)
			return;

		setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);

		scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);

		if (copyAngle)
			angle = sprTracker.angle + angleAdd;

		if (copyAlpha)
			alpha = sprTracker.alpha * alphaMult;

		if (copyVisible) 
			visible = sprTracker.visible;

		if (copySize)
		{
			width = sprTracker.width * widthMultiplier + widthAdd;
			height = sprTracker.height * heightMultiplier + heightAdd;
		}
	}
}
