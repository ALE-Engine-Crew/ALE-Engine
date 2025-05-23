package core.structures;

@:structInit class SaveData
{
	public var vSync:Bool = false;

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