package funkin.visuals.objects;

import ale.ui.*;

class CharacterPropertiesSection extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var black:FlxSprite;
    public var outline:FlxSprite;

    public var show(default, set):Bool = false;

    function set_show(value:Bool):Bool
    {
        show = value;

        if (show)
        {
            FlxTween.cancelTweensOf(this);
            FlxTween.tween(this, {x: initialX, alpha: 1}, 0.3, {ease: FlxEase.circInOut});
        } else {
            FlxTween.cancelTweensOf(this);
            FlxTween.tween(this, {x: FlxG.width - bg.width / 2, alpha: 0.5}, 0.3, {ease: FlxEase.circInOut});
        }

        return show;
    }

    public final initialX:Float = 0;

    override public function new(width:Int, height:Int, ?window:ALEWindow, ?color:FlxColor = null)
    {
        super();

        if (color == null)
            color = ClientPrefs.data.buttonTheme;

        bg = new FlxSprite().makeGraphic(width, height, color);

        black = new FlxSprite(-1).makeGraphic(width, height, color);
        add(black);

        outline = new FlxSprite(-1).makeGraphic(1, height, FlxColor.WHITE);
        add(outline);
        
        add(outline);
        add(bg);

        x = FlxG.width - width;
        initialX = x;
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this))
		{
			if (!show)
				show = true;
		} else if (show) {
			show = false;
		}
	}
}