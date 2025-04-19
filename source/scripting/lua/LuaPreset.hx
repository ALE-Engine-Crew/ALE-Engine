package scripting.lua;

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
    }
}