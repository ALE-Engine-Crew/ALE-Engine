package core.structures;

typedef ALEStage = {
    var opponentsPosition:Array<Array<Int>>;
    var playersPosition:Array<Array<Int>>;
    var extrasPosition:Array<Array<Int>>;

    var opponentsCamera:Array<Array<Int>>;
    var playersCamera:Array<Array<Int>>;
    var extrasCamera:Array<Array<Int>>;

    var format:String;

    @:optional var cameraZoom:Float;
    @:optional var cameraSpeed:Float;
}