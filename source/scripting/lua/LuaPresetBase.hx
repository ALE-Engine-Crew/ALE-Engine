package scripting.lua;

import haxe.ds.StringMap;

import core.enums.ScriptType;

class LuaPresetBase
{
    public var variables:StringMap<Dynamic>;
    public var lua:LuaScript;
    public var type:ScriptType;

    public function new(lua:LuaScript)
    {
        this.lua = lua;
        
        this.type = lua.type;

        variables = lua.variables;
    }

    public inline function set(name:String, value:Dynamic)
    {
        if (Reflect.isFunction(value))
            lua.setFunction(name, value);
        else
            lua.set(name, value);
    }

    public inline function errorPrint(text:String)
    {
        if (type == STATE)
            ScriptState.instance.debugPrint(text, FlxColor.RED);
        else
            ScriptSubState.instance.debugPrint(text, FlxColor.RED);
    }

    public inline function tagExists(name:String):Bool
        return variables.exists(name);

    public inline function getTag(name:String):Dynamic
    {
        if (tagExists(name))
        {
            return variables.get(name);
        } else {
            errorPrint('There is no Object with this Tag "' + name + '"');

            return null;
        }
    }

    public inline function tagIs(name:String, type:Dynamic):Bool
    {
        var result:Bool = Std.isOfType(getTag(name), type);

        if (!result)
            errorPrint('Object "' + name + '" is Not a ' + Type.typeof(type));
        
        return result;
    }

    public inline function setTag(name:String, value:Dynamic)
    {
        if (tagExists(name))
            errorPrint('There is already an object with the tag "' + name + '"');
        else
            variables.set(name, value);
    }

    public inline function removeTag(name:String)
    {
        if (tagExists(name))
            variables.remove(name);
    }
}