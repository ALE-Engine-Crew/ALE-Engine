package scripting.lua;

import scripting.lua.flixel.*;
import scripting.lua.haxe.*;

class LuaPreset
{
    public function new(lua:LuaScript)
    {
        new LuaGlobal(lua);
        new LuaColor(lua);
        new LuaSprite(lua);
        new LuaText(lua);
        new LuaReflect(lua);
        new LuaFileSystem(lua);
        new LuaSound(lua);
        new LuaTween(lua);
        new LuaKeys(lua);
        new LuaMouse(lua);
        new LuaTimer(lua);
        new LuaWindowsCPP(lua);
        new LuaCoolUtil(lua);
    }
}