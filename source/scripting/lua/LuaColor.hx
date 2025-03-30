package scripting.lua;

class LuaColor extends LuaPresetBase
{
    public function new(lua:LuaScript)
    {
        super(lua);

        set('colorFromString', CoolUtil.colorFromString);

        set('colorFromRGB', FlxColor.fromRGB);

        set('colorFromName', function(name:String)
            {
                name = name.toUpperCase();

                var result:Null<FlxColor> = switch(name)
                {
                    case 'BLACK': FlxColor.BLACK;
                    case 'BLUE': FlxColor.BLUE;
                    case 'BROWN': FlxColor.BROWN;
                    case 'CYAN': FlxColor.CYAN;
                    case 'GRAY': FlxColor.GRAY;
                    case 'GREEN': FlxColor.GREEN;
                    case 'LIME': FlxColor.LIME;
                    case 'MAGENTA': FlxColor.MAGENTA;
                    case 'ORANGE': FlxColor.ORANGE;
                    case 'PINK': FlxColor.PINK;
                    case 'PURPLE': FlxColor.PURPLE;
                    case 'RED': FlxColor.RED;
                    case 'TRANSPARENT': FlxColor.TRANSPARENT;
                    case 'WHITE': FlxColor.WHITE;
                    case 'YELLOW': FlxColor.YELLOW;
                    default: null;
                }

                if (result == null)
                    errorPrint('The color “' + name + '" does not exist (flixel.util.FlxColor)');

                return result;
            }
        );
    }
}