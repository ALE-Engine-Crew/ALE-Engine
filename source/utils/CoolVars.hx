package utils;

import core.structures.DataJson;

import haxe.ds.StringMap;

/**
 * Contains variables that can be useful
 */
class CoolVars
{
    public static var data:DataJson = {
        developerMode: false,

        initialState: 'IntroState',
        freeplayState: 'FreeplayState',
        storyMenuState: 'StoryMenuState',
        masterEditorMenu: 'MasterEditorMenu',
        mainMenuState: 'MainMenuState',

        pauseSubState: 'PauseSubState',
        gameOverScreen: 'GameOverScreen',
        transition: 'FadeTransition',

        title: 'Friday Night Funkin\': ALE Engine',
        icon: 'appIcon',

        bpm: 102,

        discordID: '1309982575368077416',
    };

    /**
     * Contains whether the Engine is outdated or not
     */
    public static var outdated:Bool = false;

    /**
     * Contains if the Developer Mode is enabled
     */
    public static var developerMode:Bool = true;

    /**
     * Contains the online version of the Engine
     */
    public static var onlineVersion:String = '';

    /**
     * Contains the Engine Version
     */
    public static var engineVersion:String = '';

    public static var skipTransIn:Bool = false;
    public static var skipTransOut:Bool = false;

    @:allow(cpp.WindowsTerminalCPP) private static var isConsoleVisible:Bool = false;

    @:allow(cpp.WindowsCPP) private static var windowLayered:Bool = false;

    public static var globalVars:StringMap<Dynamic> = new StringMap<Dynamic>();
}