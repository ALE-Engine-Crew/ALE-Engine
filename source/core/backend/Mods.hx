package core.backend;

import openfl.Lib;

import flixel.util.FlxSave;

class Mods
{
    public static var folder:String = '';

    public static function init()
    {
		var save:FlxSave = new FlxSave();
		save.bind('ALEEngineData', CoolUtil.getSavePath(false));

        if (save != null)
            folder = save.data.currentMod;
    }
}