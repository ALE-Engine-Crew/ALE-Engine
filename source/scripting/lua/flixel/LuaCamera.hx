package scripting.lua.flixel;

class LuaCamera extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('newCamera', function(tag:String, x:Float = 0, y:Float = 0, width:Int = 0, heigth:Int = 0, zoom:Float = 0)
            {
                setTag(tag, new FlxCamera(x, y, width, heigth, zoom));
            }
        );

        set('addCamera', function(tag:String, ?defaultDraw:Bool)
            {
                if (tagIs(tag, FlxCamera))
                    FlxG.cameras.add(getTag(tag), defaultDraw);
            }
        );

        set('removeCamera', function(tag:String)
            {
                if (tagIs(tag, FlxCamera))
                    if (FlxG.cameras.list.indexOf(getTag(tag)) != -1)
                        FlxG.cameras.remove(getTag(tag));
            }
        );
    }

    public static function cameraFromString(lua:LuaScript, name:String):FlxCamera
    {
        if (lua.variables.exists(name))
            if (lua.variables.get(name) is FlxCamera)
                return lua.variables.get(name);

        var result:FlxCamera = null;
        
        if (lua.type == STATE)
        {
            result = switch(name.toUpperCase())
            {
                case 'HUD', 'CAMHUD', 'CAMERAHUD':
                    ScriptState.instance.camHUD;
                default:
                    ScriptState.instance.camGame;
            };
        } else {
            result = switch(name.toUpperCase())
            {
                default:
                    ScriptSubState.instance.camGame;
            };
        }

        return result;
    }
}