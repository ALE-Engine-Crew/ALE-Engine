package core.config;

import llua.*;
import llua.Lua.Lua_helper;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends /* flixel.FlxState */ MusicBeatState
{
    override function create()
    {
        super.create();
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

		CoolUtil.loadSong('stress', 'hard');

        //MusicBeatState.switchState(new CustomState('introState'));
    }
}