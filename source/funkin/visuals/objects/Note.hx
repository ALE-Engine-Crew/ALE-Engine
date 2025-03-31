package funkin.visuals.objects;

import core.enums.ALECharacterType;

import funkin.visuals.objects.StrumNote;
import funkin.visuals.objects.Character;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

/**
 * It is an extension of FlxSprite that handles Notes
 */
class Note extends FlxSpriteGroup
{   
    public var scrollSpeed:Float = 1;

    public var sprite:FlxSprite;

    public var noteData:Int;

    public var type:ALECharacterType;

    public var strumTime:Float;

    public var noteLength:Float;

    public var strum:StrumNote;

    public var character:Character;

    public var hitOffset:Float = 125;

    override public function new(type:ALECharacterType, noteData:Int, strumTime:Float, noteLength:Float, character:Character, strum:StrumNote)
    {
        super();

        this.noteData = noteData;

        this.type = type;

        this.strumTime = strumTime;

        this.noteLength = noteLength;

        this.strum = strum;

        this.character = character;
        
        sprite = new FlxSprite();
        sprite.frames = Paths.getSparrowAtlas('notes/' + strum.texture);

        sprite.animation.addByPrefix('idle', switch(noteData % 4)
            {
                case 0: 'purple0';
                case 1: 'blue0';
                case 2: 'green0';
                case 3: 'red0';
                default: null;
            },
        24, false);
        
        sprite.animation.play('idle');

        sprite.centerOffsets();
        sprite.centerOrigin();

        sprite.scale.set(0.7, 0.7);

        sprite.antialiasing = ClientPrefs.data.antialiasing;

        sprite.updateHitbox();

        add(sprite);

        var rgbPalette = new RGBPalette();
        var shaderRef = new RGBShaderReference(sprite, rgbPalette);
        var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
        shaderRef.r = shaderArray[0];
        shaderRef.g = shaderArray[1];
        shaderRef.b = shaderArray[2];

        y = FlxG.height;
    }   

    public var direction(get, never):Float;

    function get_direction():Float
    {
        return strum == null ? 90 : strum.direction * Math.PI / 180;
    }

    public var distance(get, never):Float;
    
    function get_distance():Float
    {
        return (Conductor.songPosition - strumTime) * -scrollSpeed;
    }

    public var distanceX(get, never):Float;

    function get_distanceX():Float
    {
        return strum == null ? 0 : strum.x + strum.sprite.width / 2 - sprite.width / 2 + Math.cos(direction) * distance;
    }

    public var distanceY(get, never):Float;

    function get_distanceY():Float
    {
        return strum == null ? 0 : strum.y + Math.sin(direction) * distance;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (strum != null && sprite != null && sprite.alive)
        {
            if ((x < FlxG.width && x > -sprite.width) || (distanceX < FlxG.width && distanceX > -sprite.width))
                x = distanceX;
            
            if ((y < FlxG.height && y > -sprite.height) || (distanceY < FlxG.height && distanceY > -sprite.height))
                y = distanceY;

            visible = y < FlxG.height && y > -sprite.height && x < FlxG.width && x > -sprite.width;

            if (y < strum.y)
                kill();
        }
    }
}