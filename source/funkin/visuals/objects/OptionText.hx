package funkin.visuals.objects;

import core.enums.OptionsBasicType;

import core.structures.OptionsOption;

import funkin.visuals.objects.Alphabet;

class OptionText extends FlxSpriteGroup
{
    public var text:Alphabet;
    public var extraText:Alphabet;
    public var checkBox:FlxSprite;

    public final type:OptionsBasicType;

    public var value(default, set):Dynamic;
    function set_value(v:Dynamic):Dynamic
    {
        value = v;

        if (type == INTEGER || type == FLOAT)
        {
            value = FlxMath.bound(value, min, max);

            value = CoolUtil.floorDecimal(value, type == FLOAT ? decimals : 0);
        }

        switch (type)
        {
            case BOOL:
                switch (value)
                {
                    case false:
                        checkBox.animation.play('false', true);
                    case true:
                        checkBox.animation.play('true', true);
                }
            default:
                extraText.text = value;
        }

        if (Reflect.field(ClientPrefs.data, variable) == null)
            Reflect.setField(ClientPrefs.custom, variable, value);
        else
            Reflect.setField(ClientPrefs.data, variable, value);

        return value;
    }

    public final strings:Array<String>;

    public final change:Float;
    public final decimals:Int;
    public final variable:String;
    public final min:Float;
    public final max:Float;

    override public function new(option:OptionsOption)
    {
        super();

        type = option.type;

        variable = option.variable;

        strings = option.strings;
        
        change = option.change;
        decimals = option.decimals;
        min = option.min;
        max = option.max;

        text = new Alphabet(x, y, option.name + (option.type == BOOL ? '' : ':'));
        text.scaleX = text.scaleY = 0.75;
        add(text);
        
        switch (type)
        {
            case BOOL:
                checkBox = new FlxSprite();
                checkBox.frames = Paths.getSparrowAtlas('ui/checkBox');
                checkBox.animation.addByPrefix('start', 'start', 24, false);
                checkBox.animation.addByPrefix('finish', 'finish', 24, false);
                checkBox.animation.addByPrefix('true', 'true', 24, false);
                checkBox.animation.addByPrefix('false', 'false', 24, false);
                checkBox.antialiasing = ClientPrefs.data.antialiasing;
                checkBox.animation.onFrameChange.add((name:String, frameNumber:Int, frameIndex:Int) -> {
                    switch (name)
                    {
                        case 'start':
                            checkBox.offset.set(6, 6);
                        case 'true':
                            checkBox.offset.set(25, 13);
                        case 'false':
                            checkBox.offset.set(19, 15);
                        case 'finish':
                            checkBox.offset.set(5, 1);
                        default:
                    }
                });
                checkBox.animation.onFinish.add((name:String) -> {
                    switch (name)
                    {
                        case 'true':
                            checkBox.animation.play('start');
                        case 'false':
                            checkBox.animation.play('finish');
                        default:
                    }
                });
                checkBox.centerOffsets();
                checkBox.x = text.width + 5;
                checkBox.y = text.height / 2 - checkBox.height / 2;
                checkBox.scale.set(0.5, 0.5);
                add(checkBox);
            default:
                extraText = new Alphabet(0, 0, option.initialValue, false);
                extraText.x = text.width + 20;
                extraText.y = -40;
                extraText.scaleX = extraText.scaleY = 0.8;
                extraText.snapToPosition();
                extraText.antialiasing = ClientPrefs.data.antialiasing;
                add(extraText);
        }

        if (Reflect.field(ClientPrefs.data, variable) == null)
            value = option.initialValue;
        else
            value = Reflect.field(ClientPrefs.data, variable);
    }

    public function moveRight()
    {
        if (type == BOOL)
            return;

        if (type == STRING)
        {
            if (strings.indexOf(value) == strings.length - 1)
                value = strings[0];
            else
                value = strings[strings.indexOf(value) + 1];

            return;
        }

        value += change;
    }

    public function moveLeft()
    {
        if (type == BOOL)
            return;

        if (type == STRING)
        {
            if (strings.indexOf(value) == 0)
                value = strings[strings.length - 1];
            else
                value = strings[strings.indexOf(value) - 1];

            return;
        }

        value -= change;
    }
}