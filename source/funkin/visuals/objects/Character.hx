package funkin.visuals.objects;

import core.structures.PsychCharacterJSONAnimation;

import core.structures.ALECharacterJSONAnimation;
import core.structures.ALECharacter;

import core.enums.ALECharacterType;

import haxe.ds.StringMap;

import utils.ALEParserHelper;

/**
 * It is an extension of FlxSprite that handles Characters.
 */
class Character extends FlxSprite
{
    public var name:String = 'bf';

    public var idleTimer:Float = 0;

    var data:ALECharacter;

    public var cameraOffset:Array<Float>;

    public var barColor:FlxColor;

    public var icon:String = 'bf';

    public var type:ALECharacterType;

    public var typeIndex:Int = 0;

    public var offsetsMap:StringMap<Dynamic> = new StringMap<Dynamic>();

    public var voicePrefix:String = '';

    public var voice:FlxSound;

    override public function new(char:String, type:ALECharacterType, typeIndex:Int)
    {
        super();

        name = char;

        this.type = type;

        this.typeIndex = typeIndex;

        data = ALEParserHelper.getALECharacter(char);

        frames = Paths.getSparrowAtlas(data.image);

        for (animation in data.animations)
        {
            if (animation.indices != null && animation.indices.length > 0)
                this.animation.addByIndices(animation.animation, animation.prefix, animation.indices, "", animation.framerate, animation.looped);
            else
                this.animation.addByPrefix(animation.animation, animation.prefix, animation.framerate, animation.looped);

            var offsets:Array<Int> = animation.offset;
            offsets[0] -= data.position[0];
            offsets[1] -= data.position[1];

            offsetsMap.set(animation.animation, offsets);
        }

        animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
            if (offsetsMap.exists(name))
            {
                var offsets:Array<Float> = offsetsMap.get(name);

                offset.set(offsets[0], offsets[1]);
            }
        }

        antialiasing = data.antialiasing;

        scale.x = scale.y = data.scale;

        barColor = FlxColor.fromRGB(data.barColor[0], data.barColor[1], data.barColor[2]);

        icon = data.icon;

        flipX = data.flipX != (type == PLAYER);

        if (animation.exists('idle'))
            animation.play('idle');
        else if (animation.exists('danceLeft'))
            animation.play('danceLeft');

        cameraOffset = [data.cameraPosition[0] - offset.x, data.cameraPosition[0] - offset.y];

        updateHitbox();

        antialiasing = ClientPrefs.data.antialiasing;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (idleTimer <= 60 / Conductor.bpm)
            idleTimer += elapsed;
    }
}