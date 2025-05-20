package core.structures;

import core.enums.DialogueBoxState;

typedef ALEDialogueLine = {
    var character:String;
    var animation:String;
    var text:String;
    var boxState:DialogueBoxState;
    var speed:Float;
    @:optional var sound:Null<String>;
}