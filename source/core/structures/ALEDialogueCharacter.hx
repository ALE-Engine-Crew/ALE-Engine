package core.structures;

import core.enums.Alignment;

typedef ALEDialogueCharacter = {
    var image:String;

    var position:Alignment;

    var antialiasing:Bool;

    var animations:Array<ALEDialogueCharacterJSONAnimation>;

    var screenPosition:Array<Int>;

    var scale:Float;
    
    var format:String;
}