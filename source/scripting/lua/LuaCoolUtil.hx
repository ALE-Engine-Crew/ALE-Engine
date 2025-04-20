package scripting.lua;

import funkin.visuals.shaders.ALERuntimeShader;

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

                CoolUtil.setCameraShaders(cameraFromString(lua, camera), procShaders);
            }
        );

        set('setShaderInt', function(tag:String, id:String, int:Int)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloat(id, int);
            }
        );

        set('setShaderFloat', function(tag:String, id:String, float:Float)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloat(id, float);
            }
        );

        set('setShaderBool', function(tag:String, id:String, bool:Bool)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloat(id, bool);
            }
        );

        set('setSpriteShader', function(spriteTag:String, shaderTag:String)
            {
                if (tagIs(spriteTag, FlxSprite) && tagIs(shaderTag, ALERuntimeShader))
                    getTag(spriteTag).shader = getTag(shaderTag);
            }
        );
    }

    function cameraFromString(lua:LuaScript, camera:String):FlxCamera
    {
        return switch (camera.toLowerCase().trim())
        {
            case 'camhud', 'hud', 'camerahud':
                if (lua.type == STATE)
                    ScriptState.instance.camHUD;
                else
                    ScriptState.instance.camGame;
            default:
                if (lua.type == STATE)
                    ScriptState.instance.camGame;
                else
                    ScriptState.instance.camGame;
        };
    }
}