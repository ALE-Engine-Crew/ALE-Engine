package visuals.objects;

import haxe.ds.StringMap;

typedef JSONAnimation = {
    offsets:Array<Float>,
    loop:Bool,
    fps:Int,
    anim:String,
    indices:Array<Int>,
    name:String
}

/**
 * It is an extension of FlxSprite that handles Characters.
 */
class Character extends FlxSprite
{
    public var name:String = 'bf';

    public var idleTimer:Float = 0;

    var jsonAnimations:Array<JSONAnimation>;

    var jsonData:Dynamic = null;

    public var cameraOffset:Array<Float>;

    public var barColors:Array<Int>;

    public var icon:String = 'bf';

    override public function new(char:String, isPlayer:Bool)
    {
        super();

        name = char;

        antialiasing = ClientPrefs.data.antialiasing;

        if (Paths.fileExists('characters/' + char + '.json'))
            jsonData = tjson.TJSON.parse(sys.io.File.getContent(Paths.getPath('characters/' + char + '.json')));

        if (jsonData != null)
        {
            scale.x = scale.y = jsonData.scale;
            updateHitbox();

            frames = Paths.getSparrowAtlas(jsonData.image);

            jsonAnimations = jsonData.animations;

            var animsMap:StringMap<Dynamic> = new StringMap<Dynamic>();
            
            for (animation in jsonAnimations)
            {
                if(animation.indices != null && animation.indices.length > 0)
                    this.animation.addByIndices(animation.anim, animation.name, animation.indices, "", animation.fps, animation.loop);
                else
                    this.animation.addByPrefix(animation.anim, animation.name, animation.fps, animation.loop);

                var offsets:Array<Float> = animation.offsets;
                offsets[0] -= jsonData.position[0];
                offsets[1] -= jsonData.position[1];

                animsMap.set(animation.anim, offsets);
            }

            animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
                if (animsMap.exists(name))
                {
                    var offsets:Array<Float> = animsMap.get(name);
                    this.offset.set(offsets[0], offsets[1]);
                }
            }

            barColors = jsonData.healthbar_colors;

            icon = jsonData.healthicon;

            flipX = jsonData.flip_x != isPlayer;

            animation.play('idle');

            var camX = jsonData.camera_position[0] - offset.x;
            var camY = jsonData.camera_position[0] - offset.y;

            cameraOffset = [camX, camY];
        }
    }
}