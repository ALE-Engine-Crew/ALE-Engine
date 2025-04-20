package scripting.lua.flixel;

class LuaMouse extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('mouseJustPressed', function(?button:String = 'left'):Bool
            {
                return switch (button.toLowerCase().trim())
                {
                    case 'right':
                        FlxG.mouse.justPressedRight;
                    case 'middle':
                        FlxG.mouse.justPressedMiddle;
                    default:
                        FlxG.mouse.justPressed;
                }
            }
        );

        set('mousePressed', function(?button:String = 'left'):Bool
            {
                return switch (button.toLowerCase().trim())
                {
                    case 'right':
                        FlxG.mouse.pressedRight;
                    case 'middle':
                        FlxG.mouse.pressedMiddle;
                    default:
                        FlxG.mouse.pressed;
                }
            }
        );

        set('mouseJustReleased', function(?button:String = 'left'):Bool
            {
                return switch (button.toLowerCase().trim())
                {
                    case 'right':
                        FlxG.mouse.justReleasedRight;
                    case 'middle':
                        FlxG.mouse.justReleasedMiddle;
                    default:
                        FlxG.mouse.justReleased;
                }
            }
        );

        set('mouseReleased', function(?button:String = 'left'):Bool
            {
                return switch (button.toLowerCase().trim())
                {
                    case 'right':
                        FlxG.mouse.releasedRight;
                    case 'middle':
                        FlxG.mouse.releasedMiddle;
                    default:
                        FlxG.mouse.released;
                }
            }
        );

        set('mouseOverlaps', function(tag:String, ?camera:String = 'camGame')
            {
                return FlxG.mouse.overlaps(getTag(tag), LuaGlobal.cameraFromString(lua, camera));
            }
        );

        set('getMousePosition', function(type:String):Float
            {
                return switch (type)
                {
                    case 'x':
                        FlxG.mouse.x;
                    case 'y':
                        FlxG.mouse.y;
                    case 'screenX':
                        FlxG.mouse.screenX;
                    case 'screenY':
                        FlxG.mouse.screenY;
                    default:
                        0;
                }
            }
        );

        set('getMouseWorldPosition', function(type:String, ?camera:String = ''):Float
            {
                return switch (type)
                {
                    case 'y':
                        FlxG.mouse.getWorldPosition(cameraFromString(lua, camera)).y;
                    default:
                        FlxG.mouse.getWorldPosition(cameraFromString(lua, camera)).x;
                }
            }
        );

        set('getMouseScreenPosition', function(type:String, ?camera:String = ''):Float
            {
                return switch (type)
                {
                    case 'y':
                        FlxG.mouse.getScreenPosition(cameraFromString(lua, camera)).y;
                    default:
                        FlxG.mouse.getScreenPosition(cameraFromString(lua, camera)).x;
                }
            }
        );

        set('getMouseWheel', function():Float
            {
                return FlxG.mouse.wheel;
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