package visuals.options;

import core.enums.OptionsBasicType;

import core.structures.OptionsOption;

import funkin.visuals.objects.Alphabet;
import funkin.visuals.objects.AttachedAlphabet;
import funkin.visible.objects.AttachedSprite;

class OptionText extends FlxSpriteGroup
{
    public var data:OptionsOption;

    public var text:Alphabet;
    public var numText:AttachedAlphabet;
    public var checkBox:AttachedSprite;

    override public function new(option:OptionsOption, index:Int, offIndex:Int)
    {
        super();

        data = option;

        text = new Alphabet(x, y, theText:String);
        text.scaleX = alpha.scaleY = 0.75;
        add(text);
        text.alpha = 0;        
    }
}

/*
    var optionData:StringMap<Dynamic> = new StringMap<Dynamic>();

    optionData.set('type', option.type);

    var alpha:Alphabet = new Alphabet(FlxG.width + 175 - Math.pow(1.75, Math.abs(offIndex)) * 25, 300 + 75 * offIndex, option.name + (option.type == 'bool' ? '' : ':'));
    alpha.scaleY = alpha.scaleX = 0.75;
    optSprites.add(alpha);
    alpha.alpha = 0;
    FlxTween.tween(alpha, {alpha: index == selInt.options ? 1 : 0.5}, 0.5, {ease: FlxEase.circInOut});

    optionData.set('text', alpha);

    switch(option.type)
    {
        case 'bool':
            var checkBox:AttachedSprite = new AttachedSprite();
            checkBox.frames = Paths.getSparrowAtlas('ui/checkBox');
            checkBox.animation.addByPrefix('start', 'start', 24, false);
            checkBox.animation.addByPrefix('finish', 'finish', 24, false);
            checkBox.animation.addByPrefix('true', 'true', 24, false);
            checkBox.animation.addByPrefix('false', 'false', 24, false);
            checkBox.animation.play(option.initialValue ? 'start' : 'finish');
            checkBox.antialiasing = ClientPrefs.data.antialiasing;
            checkBox.animation.callback = (name:String) -> {
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
                }
            }
            checkBox.animation.finishCallback = (name:String) -> {
                switch (name)
                {
                    case 'true':
                        checkBox.animation.play('start');
                    case 'false':
                        checkBox.animation.play('finish');
                }
            }
            checkBox.centerOffsets();
            checkBox.sprTracker = alpha;
            checkBox.xAdd = alpha.width + 5;
            checkBox.yAdd = alpha.height / 2 - checkBox.height / 2;
            checkBox.scale.set(0.5, 0.5);
            if (optionData.get('blocked')) checkBox.color = FlxColor.fromRGB(100, 100, 125);
            optSprites.add(checkBox);
        
            optionData.set('checkBox', checkBox);
        case 'integer', 'float', 'string':
            var attaText:AttachedAlphabet = new AttachedAlphabet(option.initialValue, alpha.width + 20, -40, false, 0.8);
            attaText.snapToPosition();
            attaText.antialiasing = ClientPrefs.data.antialiasing;
            attaText.alpha = 0.25;
            attaText.sprTracker = alpha;
            attaText.copyAlpha = true;
            optSprites.add(attaText);

            optionData.set('attaText', attaText);
    }
*/