package funkin.visuals.objects;

import core.enums.ControlsAlphabetType;

import flixel.input.keyboard.FlxKey;

class ControlsAlphabet extends Alphabet
{
    public var type:ControlsAlphabetType;

    public var category:String;
    public var variable:String;

    override public function new(y:Float, theText:String = '---', type:ControlsAlphabetType, category:String = '', variable:String = '')
    {
        super(0, y, theText.toUpperCase().replace('_', ' ').replace('-', '_'), type == MENU || type == TITLE);

        var theScale:Float = type == TITLE ? 1 : type == MENU ? 0.75 : 0.6;

        setScale(theScale, theScale);

        alpha = type == MAIN_OPTION || type == ALT_OPTION ? 0.3 : 1;

        x = type == CATEGORY ? 150 : type == ALT_OPTION ? FlxG.width - 150 - width : FlxG.width / 2 - width / 2;

        if (type != MENU && type != TITLE)
            for (letter in members)
                letter.colorTransform.blueOffset = letter.colorTransform.redOffset = letter.colorTransform.greenOffset = 255;

        this.type = type;

        this.category = category;
        this.variable = variable;
    }

    public function setKeyText(int:Int)
    {
        text = FlxKey.toStringMap.get(int);

        for (letter in members)
            letter.colorTransform.blueOffset = letter.colorTransform.redOffset = letter.colorTransform.greenOffset = 255;

        x = Math.floor(type == ALT_OPTION ? FlxG.width - 150 - width : FlxG.width / 2 - width / 2);

        Reflect.field(Reflect.field(ClientPrefs.data.controls, category), variable)[type == ALT_OPTION ? 1 : 0] = int;
    }
}