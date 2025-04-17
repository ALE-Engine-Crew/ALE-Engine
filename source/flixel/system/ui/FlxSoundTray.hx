package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

class FlxSoundTray extends Sprite
{
	public var active:Bool;

	var _timer:Float;

	var _bars:Array<Bitmap>;

	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	public var volumeUpSound:String = '';

	public var volumeDownSound:String = '';

	public var silent:Bool = false;

	public var _y:Float;

	public var _alpha:Float = 1;

	@:keep public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#end

		var dtf:TextFormat = new TextFormat(Paths.font('rajdhani.ttf'), 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		text.text = "VOLUME";
		text.y = 16;

		addChild(text);

		var bx:Int = 10;

		var by:Int = 14;

		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;

			addChild(tmp);

			_bars.push(tmp);

			bx += 6;
			by--;
		}

		y = _y = -height;

		visible = false;
	}
	
	public function update(elapsed:Float):Void
	{
		y = CoolUtil.fpsLerp(y, _y, 0.15);

		alpha = CoolUtil.fpsLerp(alpha, _alpha, 0.15);
		
		if (_timer > 0)
		{
			_timer -= elapsed / 750;
		} else if (y > -height) {
			_y = -height;

			_alpha = 0;

			if (y <= -height)
			{
				visible = active = false;

				#if FLX_SAVE
				if (FlxG.save.isBound)
				{
					FlxG.save.data.mute = FlxG.sound.muted;
					FlxG.save.data.volume = FlxG.sound.volume;
					FlxG.save.flush();
				}
				#end
			}
		}
	}
	
	public function show(up:Bool = false):Void
	{
		if (!silent)
			FlxG.sound.play(Paths.sound('tick'), 0.75);

		_timer = _alpha = 1;

		_y = 0;

		visible = active = true;

		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
			globalVolume = 0;

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
				_bars[i].alpha = 1;
			else
				_bars[i].alpha = 0.5;
		}
	}

	public function screenCenter():Void
	{
		scaleX = scaleY = _defaultScale;

		x = 0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x;
	}
}
#end