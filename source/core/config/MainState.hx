package core.config;

import funkin.debug.DebugCounter;

import flixel.input.keyboard.FlxKey;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends MusicBeatState
{
    public static var debugCounter:DebugCounter;

    override function create()
    {
        super.create();

		FlxG.fixedTimestep = false;
        
		FlxG.game.focusLostFramerate = 60;

		FlxG.keys.preventDefaultKeys = [TAB, SHIFT, ALT, CONTROL];

		FlxG.sound.muteKeys = [ZERO];
		FlxG.sound.volumeDownKeys = [NUMPADMINUS, MINUS];
		FlxG.sound.volumeUpKeys = [NUMPADPLUS, PLUS];

        #if cpp
        debugCounter = new DebugCounter();
        FlxG.stage.addChild(debugCounter);
        #end

        ClientPrefs.loadPrefs();
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

        CoolUtil.reloadGameMetadata();

        #if cpp
        CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
        #else
        CoolUtil.switchState(new other.ChartState(), true, true);
        #end
    }
}