package scripting.lua.flixel;

import flixel.input.keyboard.FlxKey;

class LuaKeys extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('anyKeysPressed', function(keys:Array<String>)
            {
                return FlxG.keys.anyPressed(getFlxKeys(keys));
            }
        );

        set('anyKeysJustPressed', function(keys:Array<String>)
            {
                return FlxG.keys.anyJustPressed(getFlxKeys(keys));
            }
        );

        set('anyKeysJustReleased', function(keys:Array<String>)
            {
                return FlxG.keys.anyJustReleased(getFlxKeys(keys));
            }
        );

        set('keyPressed', function(key:String)
            {
                return FlxG.keys.anyPressed([FlxKey.fromString(key)]);
            }
        );

        set('keyJustPressed', function(key:String)
            {
                return FlxG.keys.anyJustPressed([FlxKey.fromString(key)]);
            }
        );

        set('keyJustReleased', function(key:String)
            {
                return FlxG.keys.anyJustReleased([FlxKey.fromString(key)]);
            }
        );
    }

    function getFlxKeys(keys:Array<String>):Array<FlxKey>
    {
        var theKeys:Array<FlxKey> = [];

        for (key in keys)
            theKeys.push(FlxKey.fromString(key));

        return theKeys;
    }
}