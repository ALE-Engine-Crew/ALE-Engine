package scripting.lua.flixel;

import flixel.util.FlxGradient;

class LuaSprite extends LuaPresetBase
{
    public function new(lua:LuaScript)
    {
        super(lua);

        set('newSprite', function(tag:String, ?x:Float, ?y:Float, ?sprite:String)
            {
                setTag(tag, new FlxSprite(x, y, sprite == null ? null : Paths.image(sprite)));
            }
        );

        set('newGradient', function(tag:String, width:Int, height:Int, colors:Array<FlxColor>, ?chunkSize:Int = 1, ?rotation:Int = 90, ?interpolate:Bool = true)
            {
                setTag(tag, FlxGradient.createGradientFlxSprite(width, height, colors, chunkSize, rotation, interpolate));
            }
        );

        set('loadGraphic', function(tag:String, name:String, ?animated:Bool = false, ?frameWidth:Int = 0, frameHeight:Int = 0)
            {
                if (tagIs(tag, FlxSprite))
                    getTag(tag).loadGraphic(Paths.image(name), animated, frameWidth, frameHeight);
            }
        );

        set('getSparrowAtlas', function(tag:String, sprite:String)
            {
                if (tagIs(tag, FlxSprite))
                    getTag(tag).frames = Paths.getSparrowAtlas(sprite);
            }
        );

        set('makeGraphic', function(tag:String, width:Int, height:Int, ?color:FlxColor = FlxColor.WHITE)
            {
                if (tagIs(tag, FlxSprite))
                    getTag(tag).makeGraphic(width, height, color);
            }
        );

        set('addAnimationByPrefix', function(tag:String, name:String, prefix:String, ?frameRate:Float, ?looped:Bool, ?flipX:Bool, ?flipY:Bool)
            {
                if (tagIs(tag, FlxSprite))
                    getTag(tag).animation.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);
            }
        );

        set('addAnimationByIndices', function(tag:String, name:String, prefix:String, indices:Array<Int>, ?frameRate:Float, ?looped:Bool, flipX:Bool, flipY:Bool)
            {
                if(tagIs(tag, FlxSprite))
                    getTag(tag).animation.addByIndices(name, prefix, indices, null, frameRate, looped, flipX, flipY);
            }
        );

        set('playAnimation', function(tag:String, name:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
            {
                if (tagIs(tag, FlxSprite))
                    getTag(tag).animation.play(name, force, reversed, frame);
            }
        );

        set('updateHitbox', function(tag:String)
            {
                if (tagIs(tag, FlxSprite))
                    getTag(tag).updateHitbox();
            }
        );
    }
}