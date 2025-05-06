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

        /*set('addCamera', function(tag:String))'*/
    }
}