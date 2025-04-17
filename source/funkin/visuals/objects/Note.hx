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
class Note extends FlxSprite
{   
	public var noteData:Int;
	public var type:ALECharacterType;
	public var strumTime:Float;
	public var strum:StrumNote;
	public var character:Character;
	public var state:NoteState = NEUTRAL;
	public var isSustainNote:Bool = false;
	public var prevNote:Note = null;
	public var parentNote:Note = null;
	public var isSustainEnd:Bool = false;
	public var defaultHitCallback:Note -> Void;
	public var customHitCallback:Note -> Void;
	public var defaultLostCallback:Note -> Void;
	public var customLostCallback:Note -> Void;
	public var killFunction:Note -> Void;
	public var spawned:Bool = false;
	public var noteGroup:FlxTypedGroup<FlxSprite> = null;

	@:isVar public var hitOffset(get, never):Float;
	function get_hitOffset():Float return 75 * strum.scrollSpeed;

	public var ableToHit(get, never):Bool;
	function get_ableToHit():Bool
		return alive && strumTime < Conductor.songPosition + 175 && strumTime > Conductor.songPosition - 175;

	var noteAnim(get, never):String;
	function get_noteAnim():String
		return switch (noteData) {
			case 0: 'purple';
			case 1: 'blue';
			case 2: 'green';
			case 3: 'red';
			default: 'null';
		};

	public static var SUSTAIN_SIZE:Int = 44;

	public function resizeByRatio(ratio:Float)
	{
		if (isSustainNote && animation.curAnim != null && !isSustainEnd)
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	override public function new(type:ALECharacterType, noteData:Int, strumTime:Float, character:Character, strum:StrumNote, ?isSustainNote:Bool = false, ?prevNote:Note = null, ?isSustainEnd:Bool = false)
	{
		super();

		this.noteData = noteData;
		this.type = type;
		this.strumTime = strumTime;
		this.strum = strum;
		this.character = character;
		this.isSustainNote = isSustainNote;
		this.prevNote = prevNote;
		this.isSustainEnd = isSustainEnd;

		if (isSustainNote && prevNote != null)
			this.parentNote = prevNote.isSustainNote ? prevNote.parentNote : prevNote;

		frames = Paths.getSparrowAtlas('notes/' + strum.texture);

		if (isSustainNote)
		{
			animation.addByPrefix('idle', noteAnim + (isSustainEnd ? ' hold end' : ' hold piece'), 24, false);
		} else {
			animation.addByPrefix('idle', noteAnim + '0', 24, false);
		}

		animation.play('idle');

		if (!isSustainNote)
		{
			centerOffsets();
			centerOrigin();
		}

		if (prevNote != null && prevNote.isSustainNote)
		{
			prevNote.animation.play('idle');
			prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
			prevNote.updateHitbox();
		}

		antialiasing = ClientPrefs.data.antialiasing;

		var rgbPalette = new RGBPalette();
		var shaderRef = new RGBShaderReference(this, rgbPalette);
		var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
		shaderRef.r = shaderArray[0];
		shaderRef.g = shaderArray[1];
		shaderRef.b = shaderArray[2];

		flipY = isSustainEnd && ClientPrefs.data.downscroll;

		y -= 2000;

		visible = false;

		antialiasing = ClientPrefs.data.antialiasing;
        
        scale.x = scale.y = 0.7;

        updateHitbox();
	}

	public var direction(get, never):Float;
	function get_direction():Float return strum == null ? 90 : strum.direction * Math.PI / 180;

	public var distance(get, never):Float;
	function get_distance():Float return 0.45 * (Conductor.songPosition - strumTime) * strum.scrollSpeed * (ClientPrefs.data.downscroll ? 1 : -1);

	public var distanceX(get, never):Float;
	function get_distanceX():Float
		return strum == null ? 0 : strum.x + strum.width / 2 - width / 2 + Math.cos(direction) * distance;

	public var distanceY(get, never):Float;
	function get_distanceY():Float
		return strum == null ? 0 : strum.y + Math.sin(direction) * distance;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (strum != null && state != HIT && spawned)
		{
			angle = strum.angle;

            scale.x = strum.scale.x;

            if (!isSustainNote)
                scale.y = strum.scale.y;

			alpha = strum.alpha * (state == LOST ? 0.3 : isSustainNote ? 0.85 : 1);

            if ((x < FlxG.width && x > -width) || (distanceX < FlxG.width && distanceX > -width))
                x = distanceX;
            
            if ((y < FlxG.height && y > -height) || (distanceY < FlxG.height && distanceY > -height))
                y = distanceY;
			
            visible = y < FlxG.height && y > -height && x < FlxG.width && x > -width;

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

			if (Conductor.songPosition - strumTime > 500 && state == LOST)
				kill();
		}
	}

	var charAnimName(get, never):String;
	function get_charAnimName():String
		return switch (noteData) {
			case 0: 'LEFT';
			case 1: 'DOWN';
			case 2: 'UP';
			case 3: 'RIGHT';
			default: 'NULL';
		};

	public function hitFunction()
	{
		state = HIT;

		if (!isSustainNote)
		{
			strum.animation.play('hit', true);

			if (type == PLAYER && !strum.botplay)
				strum.splash.animation.play('splash', true);

			if (type != PLAYER || strum.botplay)
			{
				strum.animation.finishCallback = (name:String) -> {
					strum.animation.play('idle');
					strum.animation.finishCallback = null;
				}
			}

			kill();
		} else {
			strum.animation.play('hit', true);
		}

		if (defaultHitCallback != null)
			defaultHitCallback(this);

		if (customHitCallback != null)
			customHitCallback(this);

		character.animation.play('sing' + charAnimName, true);
		character.idleTimer = 0;

		if (character.voice != null && character.voice.volume != 1)
			character.voice.volume = 1;
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

		if (isSustainNote)
			kill();

		if (character.voice != null && character.voice.volume != 0)
			character.voice.volume = 0;
	}

	override function kill()
	{
		if (killFunction != null)
			killFunction(this);

		super.kill();
	}
}
