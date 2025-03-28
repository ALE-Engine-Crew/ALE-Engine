package visuals.objects;

import flixel.group.FlxGroup.FlxTypedGroup;

class Bar extends FlxTypedGroup<FlxSprite>
{
    public var percent(default, set):Float = 50;

    public var alpha(default, set):Float = 0;

    function set_alpha(value:Float):Float
    {
        if (value > 1)
            value = 1;
        
        if (value < 0)
            value = 0;

        alpha = value;

        bg.alpha = leftBar.alpha = rightBar.alpha = alpha;

        return value;
    }

    function set_percent(value:Float):Float
    {
        if (value > 100)
            value = 100;
        
        if (value < 0)
            value = 0;
        
        percent = value;

        leftBar.scale.x = width * value / 100;
        leftBar.updateHitbox();

        rightBar.scale.x = width - leftBar.width;
        rightBar.updateHitbox();

        bg.scale.x = width + 10;
        bg.updateHitbox();

        x = x;

        return percent;
    }

    public var x(default, set):Float = 0;

    function set_x(value:Float):Float
    {
        x = value;

        leftBar.x = value;
        rightBar.x = leftBar.x + leftBar.width;
        bg.x = leftBar.x - 5;

        return value;
    }
    
    public var y(default, set):Float = 0;

    function set_y(value:Float):Float
    {
        y = value;

        leftBar.y = rightBar.y = value;
        bg.y = y - 5;

        return value;
    }

    public var width(default, set):Float = 600;

    function set_width(value:Float):Float
    {
        width = value;

        percent = percent;

        return value;
    }

    public var height(default, set):Float = 10;

    function set_height(value:Float):Float
    {
        height = value;

        leftBar.scale.y = rightBar.scale.y = value;

        leftBar.updateHitbox();
        leftBar.updateHitbox();

        bg.scale.y = height + 10;

        bg.updateHitbox();

        y = y;

        return value;
    }

    public var middlePoint(get, never):Float;

    function get_middlePoint():Float
        return leftBar.width;

    public var leftColor(default, set):FlxColor = FlxColor.WHITE;

    function set_leftColor(value:FlxColor):FlxColor
    {
        leftColor = value;

        leftBar.color = value;

        return value;
    }

    public var rightColor(default, set):FlxColor = FlxColor.WHITE;

    function set_rightColor(value:FlxColor):FlxColor
    {
        rightColor = value;

        rightBar.color = value;

        return value;
    }

    private var bg:FlxSprite;
    private var leftBar:FlxSprite;
    private var rightBar:FlxSprite;

    override public function new(?x:Float = 0, ?y:Float = 0)
    {
        super();

        leftBar = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
        leftBar.scale.set(width / 2, height);
        leftBar.updateHitbox();
        
        rightBar = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
        rightBar.scale.set(width / 2, height);
        rightBar.updateHitbox();

        bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        bg.scale.set(width + 10, height + 10);
        bg.updateHitbox();

        add(bg);
        add(leftBar);
        add(rightBar);

        this.x = x;
        this.y = y;
    }
}