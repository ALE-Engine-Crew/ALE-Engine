package core.structures;

@:keep
typedef OptionsCategory =
{
    var name:String;

    @:optional var options:Array<OptionsOption>;

    @:optional var stateData:OptionsStateData;
}