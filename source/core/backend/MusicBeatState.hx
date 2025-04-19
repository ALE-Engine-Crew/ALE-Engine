package core.backend;

import flixel.FlxState;
import flixel.FlxG;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

import funkin.visuals.objects.DebugText;

import funkin.substates.CustomTransition;

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

    private var debugTexts:FlxTypedGroup<DebugText>;
    
    override public function create()
    {
        instance = this;
        
		debugTexts = new FlxTypedGroup<DebugText>();
		add(debugTexts);

        controls = new Controls();

        if (CoolVars.skipTransOut)
            CoolVars.skipTransOut = false;
        else
            CoolUtil.openSubState(new CustomTransition(false));

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

    public var shouldClearMemory:Bool = true;

    override public function destroy()
    {
        instance = null;

        controls = null;

        debugTexts = null;

        if (shouldClearMemory)
            cleanMemory();
        
        super.destroy();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        updateMusic();
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

    private function cleanMemory()
    {
        Paths.clearEngineCache();

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