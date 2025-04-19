package scripting.lua;

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
    }
}