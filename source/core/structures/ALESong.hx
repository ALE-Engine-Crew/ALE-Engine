package core.structures;

typedef ALESong =
{
    var song:String;
    var needsVoices:Bool;
    
    var bpm:Float;
    var beats:Int;
    var steps:Int;
    
    var grids:Array<ALEGrid>;

    var events:Array<Dynamic>;
    var speed:Float;

    var stage:String;

    var format:String;
	
	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;

	@:optional var metadata:Dynamic;
	@:optional var gameOverScript:String;
	@:optional var pauseScript:String;
}