package visuals.objects;

import visuals.shaders.RGBPalette;

import visuals.shaders.RGBPalette.RGBShaderReference;

/**
 * It is an extension of FlxSprite that handles Strum Notes
 */
class StrumNote extends FlxSprite
{
    public var noteData:Int;

    public var texture(default, set):String = 'notes';

    var shaderRef:RGBShaderReference;

    function set_texture(value:String):String
    {
        texture = value;

        loadTexture(texture);

        return texture;
    }

    public var splash:Splash;

	override public function new(noteData:Int, splash:Splash)
	{
		super();

        this.noteData = noteData;

        this.splash = splash;

        y = 50;

        texture = texture;

        antialiasing = ClientPrefs.data.antialiasing;

        var rgbPalette = new RGBPalette();
        shaderRef = new RGBShaderReference(this, rgbPalette);

        var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % 4];
        shaderRef.r = shaderArray[0];
        shaderRef.g = shaderArray[1];
        shaderRef.b = shaderArray[2];
	}

    public function loadTexture(image:String)
    {
        frames = Paths.getSparrowAtlas('notes/' + image);

        switch (noteData % 4)
        {
            case 0:
                animation.addByPrefix('idle', 'arrowLEFT');
                animation.addByIndices('pressed', 'left press', [0, 1], '', 24, true);
                animation.addByIndices('released', 'left press', [3], '', 24, false);
                animation.addByIndices('hit', 'left confirm', [0, 1], '', 24, false);
            case 1:
                animation.addByPrefix('idle', 'arrowDOWN');
                animation.addByIndices('pressed', 'down press', [0, 1], '', 24, true);
                animation.addByIndices('released', 'down press', [3], '', 24, false);
                animation.addByIndices('hit', 'down confirm', [0, 1], '', 24, false);
            case 2:
                animation.addByPrefix('idle', 'arrowUP');
                animation.addByIndices('pressed', 'up press', [0, 1], '', 24, true);
                animation.addByIndices('released', 'up press', [3], '', 24, false);
                animation.addByIndices('hit', 'up confirm', [0, 1], '', 24, false);
            case 3:
                animation.addByPrefix('idle', 'arrowRIGHT');
                animation.addByIndices('pressed', 'right press', [0, 1], '', 24, true);
                animation.addByIndices('released', 'right press', [3], '', 24, false);
                animation.addByIndices('hit', 'right confirm', [0, 1], '', 24, false);
        }

        animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
            centerOffsets();
            centerOrigin();

            if (shaderRef != null)
                shaderRef.enabled = name != 'idle';
        }

        animation.finishCallback = (name:String) -> {
            animation.play('idle');
        }
        
        animation.play('idle');

        centerOffsets();
        centerOrigin();

        scale.set(0.7, 0.7);

        x = 160 * 0.7 * noteData;

        switch (Math.floor(noteData / 4) % 2)
        {
            case 0:
                x += 50;
            case 1:
                x += FlxG.width - (160 * 0.7 * 8) - 50;
        }

        updateHitbox();
    }
}