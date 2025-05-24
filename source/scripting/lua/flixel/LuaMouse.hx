package scripting.lua.flixel;

import openfl.ui.MouseCursor;
import openfl.ui.Mouse;

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
                return FlxG.mouse.overlaps(getTag(tag), LuaCamera.cameraFromString(lua, camera));
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
                    case 'viewX':
                        FlxG.mouse.viewX;
                    case 'viewY':
                        FlxG.mouse.viewY;
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
                        FlxG.mouse.getWorldPosition(LuaCamera.cameraFromString(lua, camera)).y;
                    default:
                        FlxG.mouse.getWorldPosition(LuaCamera.cameraFromString(lua, camera)).x;
                }
            }
        );

        set('getMouseViewPosition', function(type:String, ?camera:String = ''):Float
            {
                return switch (type)
                {
                    case 'y':
                        FlxG.mouse.getViewPosition(LuaCamera.cameraFromString(lua, camera)).y;
                    default:
                        FlxG.mouse.getViewPosition(LuaCamera.cameraFromString(lua, camera)).x;
                }
            }
        );

        set('getMouseWheel', function():Float
            {
                return FlxG.mouse.wheel;
            }
        );

        set('setMouseCursor', function(type:MouseCursor)
            {
                Mouse.cursor = type;
            }
        );
    }
}