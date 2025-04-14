package funkin.debug;

import openfl.text.TextFormat;
import openfl.display.Sprite;
import openfl.text.TextField;

import flixel.util.FlxStringUtil;

#if cpp
import cpp.vm.Gc;
#end

class FPSField extends DebugField
{
    public function new()
    {
        super('FPS: 0', 26, 'Memory: [N/A]', 16);

        text.alpha = 0.75;
    }

    var fps:Float = 0;
    
    var memory:Float = 0;
    var memoryPeak:Float = 0;

    override function updateField()
    {
        fps = CoolUtil.fpsLerp(fps, FlxG.elapsed == 0 ? 0 : (1 / FlxG.elapsed), 0.25);

        title.text = 'FPS: ' + Std.string(Math.floor(fps));
        
        #if cpp
        memory = Gc.memInfo64(Gc.MEM_INFO_USAGE);

        if (memoryPeak < memory)
            memoryPeak = memory;

        text.text = 'Memory: ' + FlxStringUtil.formatBytes(memory) + ' / ' + FlxStringUtil.formatBytes(memoryPeak);
        #end
    }
}