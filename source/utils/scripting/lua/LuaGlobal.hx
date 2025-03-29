package utils.scripting.lua;

import flixel.FlxBasic;

class LuaGlobal extends LuaPresetBase
{
    public function new(lua:LuaScript)
    {
        super(lua);

        set('add', function(tag:String)
        {
            if (tagIs(tag, FlxBasic))
                game.add(getTag(tag));
        });

        set('remove', function(tag:String)
            {
                if (game.members.indexOf(getTag(tag)) != -1)
                    game.remove(getTag(tag));
                else
                    errorPrint('Object ' + tag + ' Has Not Been Added Yet');
            }
        );

        set('insert', function(position:Int, tag:String)
            {
                if (tagIs(tag, FlxBasic))
                    game.insert(position, getTag(tag));
            }
        );

        set('debugPrint', function(text:String, ?color:String)
        {
            game.debugPrint(text, color == null ? null : CoolUtil.colorFromString(color));
        });
    }
}