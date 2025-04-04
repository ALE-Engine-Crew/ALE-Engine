package funkin.visuals.objects;

import core.structures.PsychCharacterJSONAnimation;

import core.structures.ALECharacterJSONAnimation;
import core.structures.ALECharacter;

import core.enums.ALECharacterType;

import haxe.ds.StringMap;

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

    override public function new(char:String, type:ALECharacterType, typeIndex:Int)
    {
        super();

        name = char;

        this.type = type;

        this.typeIndex = typeIndex;

        data = returnALEJson(char);

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
    }

    function returnALEJson(path:String):ALECharacter
    {
        if (Paths.fileExists('characters/' + path + '.json'))
        {
            var theJson:Dynamic = Json.parse(File.getContent(Paths.getPath('characters/' + path + '.json')));

            if (theJson.format == 'ale-format-v0.1')
            {
                return theJson;
            } else {
                var newAnims:Array<ALECharacterJSONAnimation> = [];

                var psychAnims:Array<PsychCharacterJSONAnimation> = cast theJson.animations;

                for (anim in psychAnims)
                {
                    newAnims.push(
                        {
                            offset: anim.offsets,
                            looped: anim.loop,
                            framerate: anim.fps,
                            animation: anim.anim,
                            indices: anim.indices,
                            prefix: anim.name
                        }
                    );
                }

                var formattedJson:ALECharacter = {
                    animations: newAnims,

                    image: theJson.image,
                    flipX: theJson.flip_x,
                    antialiasing: !theJson.no_antialiasing,

                    position: theJson.position,
                
                    icon: theJson.healthicon,
                
                    barColor: theJson.healthbar_colors,
                
                    cameraPosition: theJson.camera_position,
                
                    scale: theJson.scale,
                
                    format: 'ale-format-v0.1'
                };

                return cast formattedJson;
            }
        } else {
            return {
                animations: [],

                image: 'bf',
                flipX: false,
                antialiasing: true,
            
                position: [0, 0],
            
                icon: 'bf',
            
                barColor: [255, 255, 255],
            
                cameraPosition: [0, 0],
            
                scale: 1,
            
                format: 'ale-format-v0.1',
            };
        }
    }
}