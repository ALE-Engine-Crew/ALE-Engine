package visuals.objects;

import core.enums.ALECharacterType;

import visuals.objects.StrumNote;

import visuals.shaders.RGBPalette;

import visuals.shaders.RGBPalette.RGBShaderReference;

/**
 * It is an extension of FlxSprite that handles Notes
 */
class Note extends FlxSprite
{
    public var strumTime:Float = 0;

    public var scrollSpeed:Float = 1;

    public var noteData:Int = 0;

    public var length:Int = 0;

    public var type:ALECharacterType;

    public var strum:StrumNote;

    public var hitCallback:Note -> Void;
    public var loseCallback:Note -> Void;
    
    public function new(id:Int, strumTime:Float, length:Int, type:ALECharacterType, strum:StrumNote)
    {
        super();

        this.strumTime = strumTime;

        noteData = id;

        this.length = length;

        this.type = type;

        this.strum = strum;

        frames = Paths.getSparrowAtlas('notes/' + 'notes');

        switch (noteData % 4)
        {
            case 0:
                animation.addByPrefix('idle', 'purple0', 24, false);
            case 1:
                animation.addByPrefix('idle', 'blue0', 24, false);
            case 2:
                animation.addByPrefix('idle', 'green0', 24, false);
            case 3:
                animation.addByPrefix('idle', 'red0', 24, false);
        }
        
        animation.play('idle');

        centerOffsets();
        centerOrigin();

        scale.set(0.7, 0.7);

        y = FlxG.height;

        //makeGraphic(100, 100 + length);

        antialiasing = ClientPrefs.data.antialiasing;

        var rgbPalette = new RGBPalette();
        var shaderRef = new RGBShaderReference(this, rgbPalette);
        var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
        shaderRef.r = shaderArray[0];
        shaderRef.g = shaderArray[1];
        shaderRef.b = shaderArray[2];
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!active || strum == null)
            return;

        y = CoolUtil.fpsLerp(y, strum.y + (strumTime * scrollSpeed) - (Conductor.songPosition * scrollSpeed), 1);
        
        x = strum.x + strum.width / 2 - this.width / 2;

        visible = y < FlxG.height || y >= -height;

        if (y <= strum.y && (type != PLAYER || PlayState.instance.botplay))
            hitFunction();
        
        if (y + height < strum.y - 150 * scrollSpeed && type == PLAYER && !PlayState.instance.botplay)
            loseFunction();
    }

    public function hitFunction()
    {
        if (hitCallback != null)
            hitCallback(this);

        kill();
        
        active = false;

        destroy();
    }

    public function loseFunction()
    {
        if (loseCallback != null)
            loseCallback(this);

        kill();
        
        active = false;

        destroy();
    }
}