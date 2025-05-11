package funkin.debug;

class ConductorField extends DebugField
{
    override public function new()
    {
        super('Conductor Info');
    }

    var theText:String = '';

    override function updateField(elapsed:Float)
    {
        theText = 'Song Position: ' + Conductor.songPosition;
        theText += '\n - Step: ' + Conductor.curStep;
        theText += '\n - Beat: ' + Conductor.curBeat;
        theText += '\n - Section: ' + Conductor.curSection;
        theText += '\nBPM: ' + Conductor.bpm;
        theText += '\nTime Signature: ' + Conductor.beatsPerSection + ' / ' + Conductor.stepsPerBeat;

        text.text = theText;
    }
}