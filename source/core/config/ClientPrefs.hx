package core.config;

@:structInit class SaveData
{
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
	public var framerate:Int = 240;

	public var checkForUpdates:Bool = true;
	
	public var discordRPC:Bool = true;

	public var offset:Int = 0;
}

class ClientPrefs
{
    public static var data:SaveData = {};

	public static var modData:Dynamic = {};

	public static function loadPrefs()
	{
		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}
}