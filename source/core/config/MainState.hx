package core.config;

import flixel.addons.display.FlxTiledSprite;

import funkin.debug.DebugCounter;

import openfl.Lib;

import lime.graphics.Image;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends MusicBeatState
{
    public static var debugCounter:DebugCounter;

    private static var iconImage:String = null;

    override function create()
    {
        super.create();

        debugCounter = new DebugCounter();

        FlxG.stage.addChild(debugCounter);

		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

        core.backend.Mods.folder = 'devMod';

        CoolUtil.reloadGameMetadata();

        if (iconImage != CoolVars.data.icon)
        {
            if (Paths.fileExists(CoolVars.data.icon + '.png'))
            {
                iconImage = CoolVars.data.icon;

                Lib.current.stage.window.setIcon(Image.fromFile(Paths.getPath(CoolVars.data.icon + '.png')));
            }
        }

        FlxG.stage.window.title = CoolVars.data.title;

        CoolUtil.switchState(new CustomState(CoolVars.data.initialState));
    
        //CoolUtil.loadSong('stress', 'hard');

        //CoolUtil.switchState(new funkin.editors.CharacterEditorState());
    }
}