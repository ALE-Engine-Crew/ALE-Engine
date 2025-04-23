package core.structures;

import core.enums.OptionsBasicType;

typedef OptionsOption =
{
    var name:String;

    var description:String;

    var variable:String;

    var type:OptionsBasicType;

    var initialValue:Dynamic;

    @:optional var min:Float;
    @:optional var max:Float;
    @:optional var change:Float;
    @:optional var decimals:Float;

    @:optional var strings:Array<String>;
}