package utils;

import lime.utils.Assets as LimeAssets;
import lime.app.Application;

import flixel.FlxSprite;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.graphics.tile.FlxGraphicsShader as FlxShader;

import funkin.visuals.ALECamera;

import funkin.substates.CustomTransition;

import core.structures.*;

import openfl.system.Capabilities;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;

import core.config.MainState;

import utils.ALEParserHelper;

/**
 * It contains functions that can be quite useful
 */
class CoolUtil
{
	/**
	 * Used to capitalize a text
	 * @param text Text to capitalize
	 * @return String
	 */
	inline public static function capitalize(text:String):String
		return text.charAt(0).toUpperCase() + text.substring(1).toLowerCase();

	/**
	 * Used to load a Color from a Text
	 * @param color Text to convert
	 * @return FlxColor
	 */
	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if (color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	/**
	 * It is used to cut the number of decimals in a number
	 * @param value Number to cut
	 * @param decimals Number of decimals
	 * @return Float
	 */
	public static function floorDecimal(value:Float, decimals:Int):Float
		return FlxMath.roundDecimal(value, decimals);

	/**
	 * Used to find the dominant color in a FlxSprite
	 * @param sprite Self-explanatory
	 * @return Int
	 */
	inline public static function dominantColor(sprite:FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = new Map<Int, Int>();
		
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0) {
					if (countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0;
		countByColor[FlxColor.BLACK] = 0;
		for(key in countByColor.keys()) {
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	/**
	 * Used to open a page with a URL
	 * @param site URL
	 */
	inline public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/**
	 * Help to get the path to the Save File Location
	 * @return String
	 */
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String
	{
		final company:String = FlxG.stage.application.meta.get('company');
		
		return company + '/' + flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'));
	}

	/**
	 * Used to obtain the name of the current state
	 * @return String
	 */
	public static function getCurrentState():String
		return FlxG.state == null ? 'null' : Type.getClassName(Type.getClass(FlxG.state));

	/**
	 * Used to obtain the name of the current sub-state
	 * @return String
	 */
	public static function getCurrentSubState():String
		return FlxG.state.subState == null ? 'null' : Type.getClassName(Type.getClass(FlxG.state.subState));

	/**
	 * It serves to have a linear interpolation not affected by the frame rate
	 * @return Float
	 */
	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
		return FlxMath.lerp(v1, v2, fpsRatio(ratio));

	public static function fpsRatio(ratio:Float)
		return FlxMath.bound(ratio * FlxG.elapsed * 60, 0, 1);

	/**
	 * Opens a window containing certain information
	 * @param title Window title
	 * @param message Information to be displayed
	 */
	public static function showPopUp(title:String, message:String):Void
		FlxG.stage.window.alert(message, title);

	/**
	 * Used to reset and clean the game.
	 */
	public static function resetEngine():Void
	{
		CoolVars.skipTransIn = CoolVars.skipTransOut = true;

		if (ScriptState.instance != null)
			ScriptState.instance.destroyScripts();

		if (ScriptSubState.instance != null)
			ScriptSubState.instance.destroyScripts();

		if (FlxG.state.subState != null)
			FlxG.state.subState.close();

		for (key in CoolVars.globalVars.keys())
			CoolVars.globalVars.remove(key);

		FlxG.game.removeChild(MainState.debugCounter);
		MainState.debugCounter.destroy();
		MainState.debugCounter = null;

        #if (windows && cpp)
		cpp.WindowsCPP.setWindowBorderColor(255, 255, 255);
		#end
		
		FlxTween.globalManager.clear();

		FlxG.camera.bgColor = FlxColor.BLACK;

		FlxG.resetGame();
	}

	/**
	 * Serves to make the location of a song more flexible
	 * @param string Song Name
	 * @param difficulty Song Difficulty
	 * @return String
	 */
	public static function formatSongPath(string:String):String
	{
		string = string.replace(' ', '-').toLowerCase();

		while (string.endsWith('-'))
			string.substring(0, string.length - 1);

		while (string.startsWith('-'))
			string.substring(1);

		return string;
	}

	/**
	 * Replaces the default camera with ALE Camera
	 * @return ALECamera
	 */
	public static function initALECamera():ALECamera
	{
		var camera = new ALECamera();
		
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		
		return camera;
	}
	
	/**
	 * Used to Play a Song
	 * @param name Song Name
	 * @param difficulty Song Difficulty
	 */
	public static function loadSong(name:String, difficulty:String):Void
	{
		var jsonData:Dynamic = {};

		name = formatSongPath(name);
		
		difficulty = formatSongPath(difficulty);

		var parentFolders:Array<String> = [Paths.modFolder(), 'assets'];

		for (parentFolder in parentFolders)
		{
			if (FileSystem.exists(parentFolder + '/songs') && FileSystem.isDirectory(parentFolder + '/songs'))
			{
				for (folder in FileSystem.readDirectory(parentFolder + '/songs'))
				{
					if (name == formatSongPath(folder))
					{
						if (FileSystem.exists(parentFolder + '/songs/' + folder + '/charts/' + difficulty + '.json'))
						{
							jsonData = Json.parse(sys.io.File.getContent(parentFolder + '/songs/' + folder + '/charts/' + difficulty + '.json'));
		
							PlayState.songRoute = 'songs/' + folder;
						}
					}
				}
			}
		}

		if (jsonData == null || Reflect.fields(jsonData).length <= 0)
		{
			trace('Missing File: songs/' + name + '/charts/' + difficulty + '.json');

			return;
		}

		PlayState.SONG = ALEParserHelper.getALESong(jsonData);

		switchState(new PlayState());
	}

	public static function resizeGame(width:Int, height:Int)
	{
		FlxG.fullscreen = false;

		FlxG.initialWidth = width;
		FlxG.initialHeight = height;

		FlxG.resizeGame(width, height);

		FlxG.resizeWindow(width, height);

		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);

		for (camera in FlxG.cameras.list)
		{
			camera.width = width;
			camera.height = height;
		}
	}

	public static function adjustColorBrightness(color:FlxColor, factor:Float):FlxColor
	{
		factor = factor / 100;
	
		var r = (color >> 16) & 0xFF;
		var g = (color >> 8) & 0xFF;
		var b = color & 0xFF;
	
		if (factor > 0)
		{
			r += Std.int((255 - r) * factor);
			g += Std.int((255 - g) * factor);
			b += Std.int((255 - b) * factor);
		} else {
			r = Std.int(r * (1 + factor));
			g = Std.int(g * (1 + factor));
			b = Std.int(b * (1 + factor));
		}
	
		return FlxColor.fromRGB(r, g, b);
	}

    private static var iconImage:String = null;

	public static function reloadGameMetadata()
	{
		CoolVars.data = {
			developerMode: false,

			initialState: 'IntroState',
			freeplayState: 'FreeplayState',
			storyMenuState: 'StoryMenuState',
			masterEditorMenu: 'MasterEditorMenu',
			optionsState: 'OptionsState',

			pauseSubState: 'PauseSubState',
			gameOverScreen: 'GameOverScreen',
			transition: 'FadeTransition',

			title: 'Friday Night Funkin\': ALE Engine',
			icon: 'appIcon',

			bpm: 102.0,

			discordID: '1309982575368077416',
		};

		try
		{
			if (Paths.fileExists('data.json'))
			{
				var json:Dynamic = Json.parse(File.getContent(Paths.getPath('data.json')));

				for (field in Reflect.fields(json))
					if (Reflect.hasField(CoolVars.data, field))
						Reflect.setField(CoolVars.data, field, Reflect.field(json, field));
			}
		} catch (error:Dynamic) {
			trace('Error While Loading Game Data (data.json): ' + error);
		}

        if (iconImage != CoolVars.data.icon)
        {
            if (Paths.fileExists(CoolVars.data.icon + '.png'))
            {
                iconImage = CoolVars.data.icon;

                openfl.Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile(Paths.getPath(CoolVars.data.icon + '.png')));
            }
        }

        FlxG.stage.window.title = CoolVars.data.title;
	}

    public static inline function switchState(state:flixel.FlxState = null, skipTransIn:Bool = false, skipTransOut = false)
    {
        if (state == null)
            FlxG.resetState();

        if (state is CustomState)
        {
            var custom:CustomState = Std.downcast(state, CustomState);
            
            if (Paths.fileExists('scripts/states/' + custom.scriptName + '.hx') || Paths.fileExists('scripts/states/' + custom.scriptName + '.lua'))
                transitionSwitch(state, skipTransIn, skipTransOut);
            else
                debugPrint('Custom State called "' + custom.scriptName + '" doesn\'t Exist', FlxColor.RED);
        } else {
			transitionSwitch(state, skipTransIn, skipTransOut);
		}
    }

	private static function transitionSwitch(state:flixel.FlxState, skipTransIn, skipTransOut)
	{
		CoolVars.skipTransIn = skipTransIn;
		CoolVars.skipTransOut = skipTransOut; 

        if (CoolVars.skipTransIn)
		{
            CoolVars.skipTransIn = false;

			FlxG.switchState(state);
		} else {
            CoolUtil.openSubState(new CustomTransition(true, () -> { FlxG.switchState(state); }));
		}
	}

	public static function openSubState(subState:flixel.FlxSubState = null)
	{
		if (subState == null)
			return;

        if (subState is CustomSubState)
        {
            var custom:CustomSubState = Std.downcast(subState, CustomSubState);
            
            if (Paths.fileExists('scripts/substates/' + custom.scriptName + '.hx') || Paths.fileExists('scripts/substates/' + custom.scriptName + '.lua'))
                FlxG.state.openSubState(subState);
            else
                debugPrint('Custom SubState called "' + custom.scriptName + '" doesn\'t Exist', FlxColor.RED);

            return;
        }

		FlxG.state.openSubState(subState);
	}

	public static function debugPrint(text:Dynamic, ?color:FlxColor)
	{
		if (MusicBeatSubState.instance != null)
			MusicBeatSubState.instance.debugPrint(text, color);
		else if (MusicBeatState.instance != null)
			MusicBeatState.instance.debugPrint(text, color);
		else
			Sys.println(text);
	}
}