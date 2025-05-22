package scripting.lua;

class LuaDiscord extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('changeDiscordPresence', DiscordRPC.changePresence);
        
        set('shutdownDiscord', DiscordRPC.shutdown);

        set('updateDiscordPresence', DiscordRPC.updatePresence);
    }
}