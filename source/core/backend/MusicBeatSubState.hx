package core.backend;

/**
 * It is a FlxSubState extension that calculates the Bits, Steps and Sections of the game music (FlxG.sound.music).
 */
class MusicBeatSubState extends flixel.FlxSubState
{
    public var curStep:Int = 0;
    public var curBeat:Int = 0;
    public var curSection:Int = 0;

    public static var instance:MusicBeatSubState;

    override public function create()
    {
        instance = this;

        super.create();
    }

    override public function destroy()
    {
        instance = null;

        super.destroy();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var step:Int = Math.floor(Conductor.songPosition / 1000 * Conductor.bpm / 15);
    
        if (step > curStep)
        {
            curStep = step;
            
            stepHit();
        }
    }

    public function stepHit()
    {
        var beat:Int = Math.floor(curStep / 4);

        if (beat > curBeat)
        {
            curBeat = beat;

            beatHit();
        }
    }

    public function beatHit()
    {
        var section:Int = Math.floor(curBeat / 4);

        if (section > curSection)
        {
            curSection = section;

            sectionHit();
        }
    }

    public function sectionHit() {}

    public static function switchState(state:flixel.FlxState = null)
    {
        if (state == null) FlxG.resetState();
        else FlxG.switchState(state);
    }
}