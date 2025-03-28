package utils.scripting.lua;

import llua.Lua;
import llua.LuaL;
import llua.State;

class LuaScript
{   
    public var name:String;

    public function new(scriptName:String)
    {
        name = scriptName;

        create();
    }

    function create()
    {
        var lua:State = LuaL.newState();
        LuaL.openLibs(lua);
        if (Paths.fileExists(name + '.lua'))
            LuaL.doFile(lua, name + '.lua');
    }
}