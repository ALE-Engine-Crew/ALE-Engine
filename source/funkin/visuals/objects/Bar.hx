package funkin.visuals.objects;

import flixel.group.FlxSpriteGroup;

import flixel.math.FlxRect;

import core.enums.Orientation;

class Bar extends FlxSpriteGroup
{
    public var orientation(default, set):Orientation = LEFT;
    function set_orientation(value:Orientation):Orientation
    {
        orientation = value;

        percent = percent;

        return orientation;
    }

    public var percent(default, set):Float = 50;
    function set_percent(value:Float):Float
    {
        percent = FlxMath.bound(value, 0, 100);

        final leftWidth:Float = leftBar.width * (percent / 100);

        if (orientation == LEFT)
        {
            leftBar.clipRect = new FlxRect(0, 0, leftWidth, height);
            rightBar.clipRect = new FlxRect(leftWidth, 0, leftBar.width - leftWidth, height);
        } else if (orientation == RIGHT) {
            leftBar.clipRect = new FlxRect(0, 0, leftBar.width - leftWidth, height);
            rightBar.clipRect = new FlxRect(leftBar.width - leftWidth, 0, leftWidth, height);
        }

        return percent;
    }

    @:isVar public var middlePoint(get, never):Float = 0;
    function get_middlePoint():Float
        return width * ((orientation == LEFT ? percent : 100 - percent) / 100);

    public var bg:FlxSprite;
    public var leftBar:FlxSprite;
    public var rightBar:FlxSprite;

    override public function new(?x:Float = 0, ?y:Float = 0, width:Int = 610, height:Int = 20)
    {
        super();

        bg = new FlxSprite().makeGraphic(width, height, FlxColor.BLACK);
        add(bg);

        leftBar = new FlxSprite().makeGraphic(width - 10, height - 10);
        add(leftBar);
        leftBar.x = leftBar.y = 5;

        rightBar = new FlxSprite().makeGraphic(width - 10, height - 10);
        add(rightBar);
        rightBar.x = rightBar.y = 5;

        this.x = x;
        this.y = y;

        percent = percent;
    }
}