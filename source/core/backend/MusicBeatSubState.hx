package core.backend;

import funkin.visuals.objects.DebugText;

import core.enums.PrintType;

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

    public inline function debugPrint(text:Dynamic, ?type:PrintType = TRACE) 
    {
        var color:FlxColor = switch (type)
        {
            case ERROR:
                0xFFFF5555;
            case WARNING:
                0xFFFFA500;
            case TRACE:
                0xFFFFFFFF;
            case HSCRIPT:
                0xFF88CC44;
            case LUA:
                0xFF4466DD;
        };

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

        debugTrace(text, type);
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
            curStep = Conductor.curStep;

            stepHit(curStep);
        }
        
        if (curBeat != Conductor.curBeat)
        {
            curBeat = Conductor.curBeat;

            beatHit(curBeat);
        }
        
        if (curSection != Conductor.curSection)
        {
            curSection = Conductor.curSection;

            sectionHit(curSection);
        }
    }

    public function stepHit(curStep:Int) {}

    public function beatHit(curBeat:Int) {}

    public function sectionHit(curSection:Int) {}

    public static function switchState(state:flixel.FlxState = null)
    {
        if (state == null) FlxG.resetState();
        else FlxG.switchState(state);
    }
}