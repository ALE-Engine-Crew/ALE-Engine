package core.backend;

import funkin.visuals.objects.DebugText;

/**
 * It is a FlxSubState extension that calculates the Bits, Steps and Sections of the game music (FlxG.sound.music).
 */
class MusicBeatSubState extends flixel.FlxSubState
{
    public var curStep:Int = 0;
    public var curBeat:Int = 0;
    public var curSection:Int = 0;

    public static var instance:MusicBeatSubState;

    private var debugTexts:FlxTypedGroup<DebugText>;

    public var controls:Controls;

    override public function create()
    {
        instance = this;
        
		debugTexts = new FlxTypedGroup<DebugText>();
		add(debugTexts);

        controls = new Controls();

        super.create();
    }

    public inline function debugPrint(text:Dynamic, ?color:FlxColor = FlxColor.WHITE) 
    {
        text = Std.string(text);

        if (debugTexts != null)
        {
            var newText:DebugText = debugTexts.recycle(DebugText);
            newText.text = text;
            newText.color = color;
            newText.disableTime = 6;
            newText.alpha = 1;
            newText.setPosition(10, 8 - newText.height);
            newText.scrollFactor.set();
            
            debugTexts.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    
            debugTexts.forEachAlive(
                function (text:DebugText)
                {
                    text.y += newText.height + 2;
                }
            );
    
            debugTexts.add(newText);
        }

        Sys.println(text);
    }

    override public function destroy()
    {
        instance = null;

        controls = null;

        debugTexts = null;

        super.destroy();
    }

    private function updateMusic()
    {
        if (curStep != Conductor.curStep)
        {
            stepHit();

            curStep = Conductor.curStep;
        }
        
        if (curBeat != Conductor.curBeat)
        {
            beatHit();

            curBeat = Conductor.curBeat;
        }
        
        if (curSection != Conductor.curSection)
        {
            sectionHit();

            curSection = Conductor.curSection;
        }
    }

    public function stepHit() {}

    public function beatHit() {}

    public function sectionHit() {}

    public static function switchState(state:flixel.FlxState = null)
    {
        if (state == null) FlxG.resetState();
        else FlxG.switchState(state);
    }
}