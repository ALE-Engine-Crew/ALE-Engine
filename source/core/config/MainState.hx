package core.config;

import funkin.debug.DebugCounter;

import flixel.input.keyboard.FlxKey;

import haxe.io.Path;

import core.backend.Mods;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends MusicBeatState
{
    #if mobile
    private var showedModMenu:Bool = false;
    #end

    public static var debugCounter:DebugCounter;

    override function create()
    {
        CoolVars.skipTransOut = true;

        super.create();
        
        openalFix();

		FlxG.fixedTimestep = false;
        
		FlxG.game.focusLostFramerate = 60;

		FlxG.keys.preventDefaultKeys = [TAB, SHIFT, ALT, CONTROL];

		FlxG.sound.muteKeys = [ZERO];
		FlxG.sound.volumeDownKeys = [NUMPADMINUS, MINUS];
		FlxG.sound.volumeUpKeys = [NUMPADPLUS, PLUS];

        Mods.init();

        ClientPrefs.loadPrefs();
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

        CoolUtil.reloadGameMetadata();

        #if cpp
        debugCounter = new DebugCounter();
        
        FlxG.stage.addChild(debugCounter);

        if (ClientPrefs.data.openConsoleOnStart)
            cpp.WindowsTerminalCPP.allocConsole();
        #end

        #if mobile
        if (!showedModMenu)
        {
            CoolUtil.openSubState(new funkin.substates.ModsMenuSubState());

            showedModMenu = true;
        }
        #else
        CoolUtil.switchState(() -> new CustomState(CoolVars.data.initialState), true, true);
        #end
    }

    function openalFix()
    {
		#if desktop
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));

		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
		#end	
    }
}