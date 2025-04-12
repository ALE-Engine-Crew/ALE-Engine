package funkin.visuals.objects;

import core.enums.ALECharacterType;
import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var botplay(default, set):Bool = false;

	function set_botplay(value:Bool):Bool
	{
		botplay = value;

		if (type == PLAYER)
		{
			if (botplay)
			{
				animation.finishCallback = (name:String) -> {
					animation.play('idle');
				}
			}
			else
			{
				animation.play('idle', true);
				animation.finishCallback = (name:String) -> {}
			}
		}

		return botplay;
	}

	public var scrollSpeed:Float = 1;

	public var noteData:Int;

	public var type:ALECharacterType;

	public var texture(default, set):String = 'note';

	public var direction:Float = 90;

	var shaderRef:RGBShaderReference;

	function set_texture(value:String):String
	{
		texture = value;
		loadTexture(texture);
		return texture;
	}

	override public function new(noteData:Int, type:ALECharacterType, ?texture:String = 'note')
	{
		super();

		this.noteData = noteData;
		this.type = type;

		antialiasing = ClientPrefs.data.antialiasing;

		this.texture = texture;

		x = 160 * 0.7 * noteData;
		if (type == OPPONENT)
			x += 50;
		else
			x += FlxG.width - (160 * 0.7 * 5) + 50;

		y = ClientPrefs.data.downscroll ? FlxG.height - 150 : 50;

		var rgbPalette = new RGBPalette();

		shaderRef = new RGBShaderReference(this, rgbPalette);

		var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % 4];

		shaderRef.r = shaderArray[0];
		shaderRef.g = shaderArray[1];
		shaderRef.b = shaderArray[2];

		antialiasing = this.antialiasing = ClientPrefs.data.antialiasing;
	}

	public function loadTexture(image:String)
	{
		frames = Paths.getSparrowAtlas('notes/' + image);

		var animToPlay:String = switch (noteData % 4)
		{
			case 0: 'left';
			case 1: 'down';
			case 2: 'up';
			case 3: 'right';
			default: null;
		};

		animation.addByPrefix('idle', 'arrow' + animToPlay.toUpperCase(), 24, false);
		animation.addByPrefix('pressed', animToPlay + ' press', 24, false);
		animation.addByPrefix('hit', animToPlay + ' confirm', 24, false);

		animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
			centerOffsets();
			centerOrigin();

			if (shaderRef != null)
				shaderRef.enabled = name != 'idle';
		}

		animation.finishCallback = (name:String) -> {
			if (name == 'hit' && type != PLAYER)
				animation.play('idle');
		}

		scale.x = scale.y = 0.7;

		animation.play('idle');

		centerOffsets();
		centerOrigin();
		updateHitbox();
	}
}