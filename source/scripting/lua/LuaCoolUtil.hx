package scripting.lua;

import funkin.visuals.shaders.ALERuntimeShader;

import scripting.lua.flixel.LuaCamera;

class LuaCoolUtil extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('capitalize', CoolUtil.capitalize);

        set('floorDecimal', CoolUtil.floorDecimal);

        set('dominantColor', function(tag:String)
            {
                if (tagIs(tag, FlxSprite))
                    CoolUtil.dominantColor(getTag(tag));
            }
        );

        set('browserLoad', CoolUtil.browserLoad);

        set('getGameSavePath', CoolUtil.getSavePath);

        set('getCurrentState', CoolUtil.getCurrentState);

        set('getCurrentSubState', CoolUtil.getCurrentSubState);

        set('fpsLerp', CoolUtil.fpsLerp);

        set('fpsRatio', CoolUtil.fpsRatio);

        set('showPopUp', CoolUtil.showPopUp);

        set('resetEngine', CoolUtil.resetEngine);

        set('formatSongPath', CoolUtil.formatSongPath);

        set('loadSong', CoolUtil.loadSong);

        set('loadWeek', CoolUtil.loadWeek);
        
        set('resizeGame', CoolUtil.resizeGame);

        set('adjustColorBrightness', CoolUtil.adjustColorBrightness);

        set('createRuntimeShader', function(tag:String, file:String)
            {
                if (CoolUtil.createRuntimeShader(file) != null)
                    setTag(tag, CoolUtil.createRuntimeShader(file));
            }
        );

        set('setCameraShaders', function(camera:String, shaderTags:Array<String>)
            {
                var procShaders:Array<ALERuntimeShader> = [];

                for (tag in shaderTags)
                    if (tagIs(tag, ALERuntimeShader))
                        procShaders.push(getTag(tag));

                CoolUtil.setCameraShaders(LuaCamera.cameraFromString(lua, camera), procShaders);
            }
        );

        set('setShaderInt', function(tag:String, id:String, int:Int)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setInt(id, int);
            }
        );

        set('getShaderInt', function(tag:String, id:String):Null<Int>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getInt(id);

                return null;
            }
        );

        set('setShaderIntArray', function(tag:String, id:String, ints:Array<Int>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setIntArray(id, ints);
            }
        );

        set('getShaderIntArray', function(tag:String, id:String):Null<Array<Int>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getIntArray(id);

                return null;
            }
        );

        set('setShaderFloat', function(tag:String, id:String, float:Float)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloat(id, float);
            }
        );

        set('getShaderFloat', function(tag:String, id:String):Null<Float>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getFloat(id);

                return null;
            }
        );

        set('setShaderFloatArray', function(tag:String, id:String, floats:Array<Float>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloatArray(id, floats);
            }
        );

        set('getShaderFloatArray', function(tag:String, id:String):Null<Array<Float>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getFloatArray(id);

                return null;
            }
        );

        set('setShaderBool', function(tag:String, id:String, bool:Bool)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setBool(id, bool);
            }
        );

        set('getShaderBool', function(tag:String, id:String):Null<Bool>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getBool(id);

                return null;
            }
        );

        set('setShaderBoolArray', function(tag:String, id:String, bools:Array<Bool>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setBoolArray(id, bools);
            }
        );

        set('getShaderBoolArray', function(tag:String, id:String):Null<Array<Bool>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getBoolArray(id);

                return null;
            }
        );

        set('setSpriteShader', function(spriteTag:String, shaderTag:String)
            {
                if (tagIs(spriteTag, FlxSprite) && tagIs(shaderTag, ALERuntimeShader))
                    getTag(spriteTag).shader = getTag(shaderTag);
            }
        );

        set('getGameSize', function(type:String)
            {
                return switch (type.toLowerCase().trim())
                {
                    case 'y':
                        FlxG.height;
                    default:
                        FlxG.width;
                }
            }
        );
    }
}