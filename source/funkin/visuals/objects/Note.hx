package funkin.visuals.objects;

import core.enums.ALECharacterType;
import core.enums.NoteState;

import funkin.visuals.objects.StrumNote;
import funkin.visuals.objects.Character;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

import flixel.math.FlxRect;

/**
 * It is an extension of FlxSprite that handles Notes
 */
class Note extends FlxSpriteGroup
{   
    public var noteData:Int;

    public var type:ALECharacterType;

    public var strumTime:Float;

    public var noteLength:Float;

    public var strum:StrumNote;

    public var character:Character;

    public var sprite:FlxSprite;

    public var state:NoteState = NEUTRAL;

    public var isSustainNote:Bool = false;

    public var prevNote:Note = null;
    
    public var parentNote:Note = null;

    public var isSustainEnd:Bool = false;

    public var defaultHitCallback:Note -> Void;
    public var customHitCallback:Note -> Void;

    public var defaultLostCallback:Note -> Void;
    public var customLostCallback:Note -> Void;

    @:isVar public var hitOffset(get, never):Float;
    
    function get_hitOffset():Float
    {
        return 75 * strum.scrollSpeed;
    }

    public var ableToHit(get, never):Bool;

    function get_ableToHit():Bool
    {
        return sprite.active && alive && strumTime < Conductor.songPosition + 175 && strumTime > Conductor.songPosition - 175;
    }

    var noteAnim(get, never):String;

    function get_noteAnim():String
    {    
        return switch (noteData)
        {
            case 0: 'purple';
            case 1: 'blue';
            case 2: 'green';
            case 3: 'red';
            default: 'null';
        }
    }

    override public function new(type:ALECharacterType, noteData:Int, strumTime:Float, noteLength:Float, character:Character, strum:StrumNote, ?isSustainNote:Bool = false, ?prevNote:Note = null, ?isSustainEnd:Bool = false)
    {
        super();

        this.noteData = noteData;
        
        this.type = type;

        this.strumTime = strumTime;

        this.noteLength = noteLength;

        this.strum = strum;

        this.character = character;

        this.isSustainNote = isSustainNote;

        this.prevNote = prevNote;

        this.isSustainEnd = isSustainEnd;

        if (isSustainNote && prevNote != null)
            this.parentNote = prevNote.isSustainNote ? prevNote.parentNote : prevNote;
        
        sprite = new FlxSprite();
        sprite.frames = Paths.getSparrowAtlas('notes/' + strum.texture);

        if (isSustainNote)
        {
            sprite.animation.addByPrefix('idle', noteAnim + (isSustainEnd ? ' hold end' : ' hold piece'), 24, false);
            sprite.scale.x = 0.7;
            sprite.scale.y = 1;
        } else {
            sprite.animation.addByPrefix('idle', noteAnim + '0', 24, false);
            
            sprite.scale.x = sprite.scale.y = 0.7;
        }

        sprite.animation.play('idle');

        sprite.centerOffsets();
        sprite.centerOrigin();

        sprite.antialiasing = ClientPrefs.data.antialiasing;
        
        add(sprite);

        var rgbPalette = new RGBPalette();
        var shaderRef = new RGBShaderReference(sprite, rgbPalette);
        var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
        shaderRef.r = shaderArray[0];
        shaderRef.g = shaderArray[1];
        shaderRef.b = shaderArray[2];

        y = FlxG.height;

        sprite.antialiasing = ClientPrefs.data.antialiasing;
    }   

    public var direction(get, never):Float;

    function get_direction():Float
    {
        return strum == null ? 90 : strum.direction * Math.PI / 180;
    }

    public var distance(get, never):Float;
    
    function get_distance():Float
    {
        return 0.45 * (Conductor.songPosition - strumTime) * -strum.scrollSpeed;
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

        if (strum != null && sprite != null && state != HIT)
        {
            angle = strum.angle;
            
            if (!isSustainNote)
                scale = strum.scale;

            alpha = strum.alpha - (state == LOST ? 0.7 : isSustainNote ? 0.15 : 0);

            if ((x < FlxG.width && x > -sprite.width) || (distanceX < FlxG.width && distanceX > -sprite.width))
                x = distanceX;
            
            if ((y < FlxG.height && y > -sprite.height) || (distanceY < FlxG.height && distanceY > -sprite.height))
                y = distanceY;

            sprite.active = visible = y < FlxG.height && y > -sprite.height && x < FlxG.width && x > -sprite.width;

            if (Conductor.songPosition >= strumTime && state == NEUTRAL && (type != PLAYER || strum.botplay))
            {
                hitFunction();

                return;
            }

            if (Conductor.songPosition >= strumTime && !ableToHit && state == NEUTRAL && !strum.botplay)
            {
                loseFunction();

                return;
            }
        }
    }

    var charAnimName(get, never):String;

    function get_charAnimName():String
    {    
        return switch (noteData)
        {
            case 0: 'LEFT';
            case 1: 'DOWN';
            case 2: 'UP';
            case 3: 'RIGHT';
            default: 'NULL';
        }
    }

    public function hitFunction()
    {
        state = HIT;

        if (!isSustainNote)
        {
            strum.sprite.animation.play('hit', true);

            if (type == PLAYER && !strum.botplay)
                strum.splash.animation.play('splash', true);

            if (type != PLAYER || strum.botplay)
            {
                strum.sprite.animation.finishCallback = (name:String) -> {
                    strum.sprite.animation.play('idle');
                    strum.sprite.animation.finishCallback = null;
                }
            }
            
            kill();
        } else {
            strum.sprite.animation.play('hit', true);
        }

        if (defaultHitCallback != null)
            defaultHitCallback(this);

        if (customLostCallback != null)
            customHitCallback(this);

        character.animation.play('sing' + charAnimName, true);
        character.idleTimer = 0;
    }

    public function loseFunction()
    {
        state = LOST;
        
        character.animation.play('sing' + charAnimName + 'miss', true);
        character.idleTimer = 0;

        if (defaultLostCallback != null)
            defaultLostCallback(this);
        
        if (customLostCallback != null)
            customLostCallback(this);

        if (!isSustainNote)
            sprite.active = false;
        
        if (isSustainNote)
            kill();
    }
}