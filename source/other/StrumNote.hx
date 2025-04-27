package other;

import core.enums.ALECharacterType;

class StrumNote extends FlxSprite
{
    public var direction:Float = 90;

    public var scrollSpeed:Float = 1;

    override public function new(type:ALECharacterType, noteData:Int)
    {
        super();

        makeGraphic(100, 100, FlxColor.GRAY);

		x = 160 * 0.7 * noteData;

		if (type == OPPONENT)
			x += 50;
		else
			x += FlxG.width - (160 * 0.7 * 5) + 50;

		y = ClientPrefs.data.downScroll ? FlxG.height - 150 : 50;
    }
}