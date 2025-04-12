package funkin.visuals.objects;

import funkin.visuals.shaders.RGBPalette;

import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

class Splash extends AttachedSprite
{
    public var noteData:Int;

    public var texture(default, set):String = 'splash';

    public var strum(default, set):StrumNote;

    function set_strum(value:StrumNote):StrumNote
    {
        strum = value;

        sprTracker = strum;
        
        xAdd = strum.width / 2 - width / 2;
        yAdd = strum.height / 2 - height / 2;

        return value;
    }

    function set_texture(value:String):String
    {
        texture = value;

        loadTexture(texture);

        return texture;
    }

    public function new(noteData:Int)
    {
        super();

        visible = false;

        this.noteData = noteData;

        var rgbPalette = new RGBPalette();
        var shaderRef:RGBShaderReference = new RGBShaderReference(this, rgbPalette);

        var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % 4];
        shaderRef.r = shaderArray[0];
        shaderRef.g = shaderArray[1];
        shaderRef.b = shaderArray[2];

        texture = texture;
    }

    function loadTexture(image:String)
    {
        frames = Paths.getSparrowAtlas('splashes/' + image);

        switch (noteData % 4)
        {
            case 0:
                animation.addByPrefix('splash', 'note splash purple 1', 24, false);
            case 1:
                animation.addByPrefix('splash', 'note splash blue 1', 24, false);
            case 2:
                animation.addByPrefix('splash', 'note splash green 1', 24, false);
            case 3:
                animation.addByPrefix('splash', 'note splash red 1', 24, false);
        }

        animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
            centerOffsets();
            centerOrigin();
            
            visible = true;
        }

        animation.finishCallback = (name:String) -> {
            visible = false;
        }

        centerOffsets();
        centerOrigin();

        scale.set(0.75, 0.75);

        updateHitbox();

        if (strum != null)
        {
            xAdd = strum.width / 2 - width / 2;
            yAdd = strum.height / 2 - height / 2;
        }
    }
}