package funkin.visuals.objects;

import core.enums.OptionsBasicType;

import core.structures.OptionsOption;

import funkin.visuals.objects.Alphabet;

class OptionText extends FlxSpriteGroup
{
    public var data:OptionsOption;

    public var text:Alphabet;
    public var extraText:Alphabet;
    public var checkBox:FlxSprite;

    public final type:OptionsBasicType;

    public var value(default, set):Dynamic;
    function set_value(v:Dynamic):Dynamic
    {
        value = v;

        switch (type)
        {
            case OptionsBasicType.BOOL:
                switch (value)
                {
                    case false:
                        checkBox.animation.play('false', true);
                    case true:
                        checkBox.animation.play('true', true);
                }
            case OptionsBasicType.STRING:
                extraText.text = value;
            default:
        }

        if (Reflect.field(ClientPrefs.data, variable) == null)
            Reflect.setField(ClientPrefs.modData, variable, value);
        else
            Reflect.setField(ClientPrefs.data, variable, value);
        
        for (val in Reflect.fields(ClientPrefs.modData))
            debugPrint(val + ': ' + Reflect.field(ClientPrefs.modData, val));
        
        return value;
    }

    public final change:Float;
    public final decimals:Float;
    public final variable:String;

    override public function new(option:OptionsOption)
    {
        super();

        data = option;

        type = data.type;

        change = option.change;

        decimals = option.decimals;

        variable = data.variable;

        text = new Alphabet(x, y, data.name + (data.type == BOOL ? '' : ':'));
        text.scaleX = text.scaleY = 0.75;
        add(text);
        
        switch (data.type)
        {
            case OptionsBasicType.BOOL:
                checkBox = new FlxSprite();
                checkBox.frames = Paths.getSparrowAtlas('ui/checkBox');
                checkBox.animation.addByPrefix('start', 'start', 24, false);
                checkBox.animation.addByPrefix('finish', 'finish', 24, false);
                checkBox.animation.addByPrefix('true', 'true', 24, false);
                checkBox.animation.addByPrefix('false', 'false', 24, false);
                checkBox.antialiasing = ClientPrefs.data.antialiasing;
                checkBox.animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
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
                }
                checkBox.animation.finishCallback = (name:String) -> {
                    switch (name)
                    {
                        case 'true':
                            checkBox.animation.play('start');
                        case 'false':
                            checkBox.animation.play('finish');
                        default:
                    }
                }
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
            value = data.initialValue;
        else
            value = Reflect.field(ClientPrefs.data, variable);
    }
}