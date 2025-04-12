package core.config;

@:structInit class SaveData
{
    public var antialiasing:Bool = true;
    public var flashing:Bool = true;
    
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];

	public var downscroll:Bool = false;

	public var cacheOnGPU:Bool = true;
}

class ClientPrefs
{
    public static var data:SaveData = {};
}