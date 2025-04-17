package funkin.debug;

class FlixelField extends DebugField
{
    override public function new()
    {
        super('Flixel Info');
    }

    var theText:String = '';

    override function updateField()
    {
        var totalBitmaps:Int = 0;

        @:privateAccess
        {
            for (_ in FlxG.bitmap._cache.keys())
                totalBitmaps++;
        }

        if (FlxG.state is CustomState)
        {
            var state:CustomState = cast FlxG.state;

            theText = 'Custom State: ' + state.scriptName;
        } else {
            theText = 'State: ' + Type.getClassName(Type.getClass(FlxG.state));
        }

        if (FlxG.state.subState is CustomSubState)
        {
            var substate:CustomSubState = cast FlxG.state.subState;

            theText += '\nCustom Sub-State: ' + substate.scriptName;
        } else {
            theText += '\nSub-State: ' + Type.getClassName(Type.getClass(FlxG.state.subState));
        }

        theText += '\nObject Count: ' + FlxG.state.members.length;
        theText += '\nCamera Count: ' + FlxG.cameras.list.length;
        theText += '\nBitmaps Count: ' + totalBitmaps;
        theText += '\nSounds Count: ' + FlxG.sound.list.length;
        theText += '\nGame Childs Count: ' + FlxG.game.numChildren;

        text.text = theText;
    }
}