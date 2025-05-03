package utils;

import core.structures.DataJson;

import haxe.ds.StringMap;

/**
 * Contains variables that can be useful
 */
class CoolVars
{
    public static var data:DataJson = null;

    /**
     * Contains whether the Engine is outdated or not
     */
    public static var outdated:Bool = false;

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