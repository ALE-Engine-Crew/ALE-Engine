package core.config;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

import core.structures.ClientControls;

import lime.app.Application;

@:structInit class SaveData
{
	public var vSync:Bool = false;

	public var controls:ClientControls = {
		notes: {
			left: [FlxKey.A, FlxKey.LEFT],
			down: [FlxKey.S, FlxKey.DOWN],
			up: [FlxKey.W, FlxKey.UP],
			right: [FlxKey.D, FlxKey.RIGHT]
		},
		ui: {
			left: [FlxKey.A, FlxKey.LEFT],
			down: [FlxKey.S, FlxKey.DOWN],
			up: [FlxKey.W, FlxKey.UP],
			right: [FlxKey.D, FlxKey.RIGHT],
			accept: [FlxKey.ENTER, FlxKey.SPACE],
			back: [FlxKey.ESCAPE, null],
			reset: [FlxKey.R, FlxKey.F5],
			pause: [FlxKey.ENTER, FlxKey.ESCAPE]
		},
		engine: {
			switch_mod: [FlxKey.SHIFT, FlxKey.M],
			reset_game: [FlxKey.SHIFT, FlxKey.F3],
			fps_counter: [FlxKey.F3, null],
			master_menu: [FlxKey.SEVEN, null]
		}
	};

    public var antialiasing:Bool = true;
    public var flashing:Bool = true;
	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	
	public var splashAlpha:Int = 60;
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];
	public var downScroll:Bool = false;
	public var ghostTapping:Bool = true;
	public var noReset:Bool = false;

	public var cacheOnGPU:Bool = true;
	public var framerate:Int = 60;

	public var checkForUpdates:Bool = true;
	
	public var discordRPC:Bool = true;

	public var offset:Int = 0;

	public var openConsoleOnStart:Bool = false;
}

class ClientPrefs
{
    public static var data:SaveData = {};

	public static var modData:Dynamic = {};

	public static function loadPrefs()
	{
		var save:FlxSave = new FlxSave();
		save.bind('defaultPreferences', CoolUtil.getSavePath());
		
		if (save != null)
		{
			for (field in Reflect.fields(save.data.settings))
				if (Reflect.field(ClientPrefs.data, field) != null)
					Reflect.setField(ClientPrefs.data, field, Reflect.field(save.data.settings, field));
		}

		var modSave:FlxSave = new FlxSave();
		modSave.bind('modPreferences', CoolUtil.getSavePath());

		if (modSave != null)
			ClientPrefs.modData = modSave.data.settings;

		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
	}

	public static function savePrefs()
	{
		var save:FlxSave = new FlxSave();
		save.bind('defaultPreferences', CoolUtil.getSavePath());
		save.data.settings = ClientPrefs.data;
		save.flush();

		var modSave:FlxSave = new FlxSave();
		modSave.bind('modPreferences', CoolUtil.getSavePath());
		modSave.data.settings = ClientPrefs.modData;
		modSave.flush();
	}
}