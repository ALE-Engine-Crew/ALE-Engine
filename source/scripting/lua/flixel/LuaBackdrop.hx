package scripting.lua.flixel;

import flixel.addons.display.FlxBackdrop;

class LuaBackdrop extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('newBackdrop', function(tag:String, ?graphic:String, ?axes:String, ?spacingX:Float, ?spacingY:Float)
            {
                setTag(tag, new FlxBackdrop(Paths.image(graphic),
                    switch (axes.toUpperCase())
                    {
                        case 'X':
                            X;
                        case 'Y':
                            Y;
                        default:
                            XY;
                    },
                    spacingX, spacingY
                ));
            }
        );
    }
}