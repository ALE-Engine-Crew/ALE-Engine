package core.config;

import flixel.addons.display.FlxTiledSprite;

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

        FlxG.updateFramerate = FlxG.drawFramerate = 240;
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

        core.backend.Mods.folder = 'REF';

		CoolUtil.loadSong('Refreshed', 'normal');

        //MusicBeatState.switchState(new CustomState('introState'));

        //MusicBeatState.switchState(new funkin.editors.CharacterEditorState());
    }
}