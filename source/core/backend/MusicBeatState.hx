package core.backend;

import flixel.FlxState;
import flixel.FlxG;

import core.backend.Controls;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

import visuals.objects.DebugText;

/**
 * It is a FlxState extension that calculates the Beats, Steps and Sections of the game music (FlxG.sound.music)
 */
class MusicBeatState extends FlxState
{
    public var curStep:Int = 0;
    public var curBeat:Int = 0;
    public var curSection:Int = 0;

    public static var instance:MusicBeatState;

    public var controls:Controls;

    var debugTexts:FlxTypedGroup<DebugText>;
    
    override public function create()
    {
        instance = this;
        
		debugTexts = new FlxTypedGroup<DebugText>();
		add(debugTexts);

        controls = new Controls();

        super.create();
    }

    public inline function debugPrint(text:String, ?color:FlxColor = FlxColor.WHITE) 
    {
		debugTexts.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        
        var newText:DebugText = debugTexts.recycle(DebugText);
        newText.text = text;
        newText.color = color;
        newText.disableTime = 6;
        newText.alpha = 1;
        newText.setPosition(10, 8 - newText.height);

        debugTexts.forEachAlive(
            function (text:DebugText)
            {
                text.y += newText.height + 2;
            }
        );

        debugTexts.add(newText);

        Sys.println(text);
    }

    override public function destroy()
    {
        instance = null;

        controls = null;

        debugTexts = null;

        cleanMemory();
        
        super.destroy();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        updateMusic();
    }

    public static inline function switchState(state:flixel.FlxState = null)
    {
        if (state == null)
            FlxG.resetState();
        else
            FlxG.switchState(state);
    }

    private function updateMusic()
    {
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

    private function cleanMemory()
    {
        #if cpp
        var killZombies:Bool = true;
        
        while (killZombies) {
            var zombie = Gc.getNextZombie();
        
            if (zombie == null) {
                killZombies = false;
            } else {
                var closeMethod = Reflect.field(zombie, "close");
        
                if (closeMethod != null && Reflect.isFunction(closeMethod)) {
                    closeMethod.call(zombie, []);
                }
            }
        }
        
        Gc.run(true);
        Gc.compact();
        #end
        
        #if hl
        Gc.major();
        #end
        
        FlxG.bitmap.clearUnused();
        FlxG.bitmap.clearCache();
    }
}