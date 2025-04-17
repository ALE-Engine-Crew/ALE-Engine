package core.config;

import funkin.debug.DebugCounter;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends MusicBeatState
{
    public static var debugCounter:DebugCounter;

    override function create()
    {
        super.create();

        debugCounter = new DebugCounter();
        FlxG.stage.addChild(debugCounter);

        ClientPrefs.loadPrefs();
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

        core.backend.Mods.folder = 'devMod';

        CoolUtil.reloadGameMetadata();

        CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
    }
}