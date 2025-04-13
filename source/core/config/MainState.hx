package core.config;

import flixel.addons.display.FlxTiledSprite;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends MusicBeatState
{
    override function create()
    {
        super.create();

        FlxG.updateFramerate = FlxG.drawFramerate = 240;
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

        core.backend.Mods.folder = 'devMod';

		CoolUtil.loadSong('stress', 'hard');

        //MusicBeatState.switchState(new CustomState('introState'));

        //MusicBeatState.switchState(new funkin.editors.CharacterEditorState());
    }
}