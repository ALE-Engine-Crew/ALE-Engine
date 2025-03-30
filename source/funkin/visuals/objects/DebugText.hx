package funkin.visuals.objects;

class DebugText extends FlxText
{
	public var disableTime:Float = 5;

	public function new()
	{
		super(10, 10, FlxG.width - 20);

		setFormat(Paths.font('rajdhani.ttf'), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		disableTime -= elapsed;

		if (disableTime < 0)
			disableTime = 0;
		
		if (disableTime < 1)
			alpha = disableTime;

		if (alpha == 0 || y >= FlxG.height)
			kill();
	}
}