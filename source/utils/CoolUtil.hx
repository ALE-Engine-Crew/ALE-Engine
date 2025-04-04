package utils;

import lime.utils.Assets as LimeAssets;

import flixel.FlxSprite;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.graphics.tile.FlxGraphicsShader as FlxShader;

import funkin.visuals.ALECamera;

import core.structures.*;

import openfl.system.Capabilities;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
import openfl.Lib;

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
		return FlxMath.lerp(v1, v2, FlxMath.bound(ratio * FlxG.elapsed * 60, 0, 1));

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
		FlxG.resetGame();

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

		for (folder in FileSystem.readDirectory('assets/songs'))
		{
			if (name == formatSongPath(folder))
			{
				if (Paths.fileExists('songs/' + folder + '/charts/' + difficulty + '.json'))
				{
					jsonData = Json.parse(sys.io.File.getContent(Paths.getPath('songs/' + folder + '/charts/' + difficulty + '.json')));

					PlayState.songRoute = 'songs/' + folder;
				} else {
					MusicBeatState.instance.debugPrint('Missing File: songs/' + folder + '/charts/' + difficulty + '.json', FlxColor.RED);

					return;
				}
			}
		}

		PlayState.SONG = returnALEJson(jsonData);

		MusicBeatState.switchState(new PlayState());
	}

	private static function returnALEJson(json:Dynamic):ALESong
	{
		var formattedJson:Dynamic = {};

		if (json.format == 'ale-format-v0.1')
		{
			return cast json;
		} else if (json.format == 'psych_v1') {
			var newJson:PsychSong = getPsychSong(json);

			formattedJson = {
				song: newJson.song,
				needsVoices: true,
				stage: newJson.stage,
				
				grids: new Array<Dynamic>(),
				events: new Array<Dynamic>(),
				metadata: {},

				bpm: newJson.bpm,
				beats: 4,
				steps: 4,

				format: 'ale-format-v0.1',
			}

			var sectionsOpponent:Array<Dynamic> = [];
			var sectionsPlayer:Array<Dynamic> = [];

			for (section in newJson.notes)
			{
				var notesPlayer:Array<Dynamic> = [];
				var notesOpponent:Array<Dynamic> = [];

				for (noteArray in section.sectionNotes)
				{
					if ((section.mustHitSection && noteArray[1] <= 3) || (!section.mustHitSection && noteArray[1] >= 4))
						notesPlayer.push(noteArray);
					else
						notesOpponent.push(noteArray);
				}

				sectionsOpponent.push(
					{
						notes: notesOpponent,

						cameraFocusThis: !section.mustHitSection
					}
				);

				sectionsPlayer.push(
					{
						notes: notesPlayer,

						cameraFocusThis: section.mustHitSection
					}
				);
			}

			formattedJson.grids.push(
				{
					sections: sectionsOpponent,
					
					character: json.player2,
					type: 'opponent'
				}
			);

			formattedJson.grids.push(
				{
					sections: sectionsPlayer,
					
					character: json.player1,
					type: 'player'
				}
			);

			formattedJson.grids.push(
				{
					sections: new Array<Dynamic>(),

					character: 'gf',
					type: 'extra'
				}
			);

			for (_ in 0...sectionsOpponent.length - 1)
			{
				formattedJson.grids[2].sections.push(
					{
						notes: new Array<Int>(),
		
						cameraFocusThis: false
					}
				);
			}
		} else {
			var newJson:PsychSong = getPsychSong(json.song);

			formattedJson = {
				song: newJson.song,
				needsVoices: true,
				speed: newJson.speed,
				stage: newJson.stage,
				
				grids: new Array<Dynamic>(),
				events: new Array<Dynamic>(),
				metadata: {},

				bpm: newJson.bpm,
				beats: 4,
				steps: 4,

				format: 'ale-format-v0.1',
			}

			var sectionsOpponent:Array<Dynamic> = [];
			var sectionsPlayer:Array<Dynamic> = [];

			for (section in newJson.notes)
			{
				var notesPlayer:Array<Dynamic> = [];
				var notesOpponent:Array<Dynamic> = [];

				for (noteArray in section.sectionNotes)
				{
					if ((section.mustHitSection && noteArray[1] <= 3) || (!section.mustHitSection && noteArray[1] >= 4))
					{
						noteArray[1] = noteArray[1] % 4;
						notesPlayer.push(noteArray);
					} else {
						noteArray[1] = noteArray[1] % 4;
						notesOpponent.push(noteArray);
					}
				}

				sectionsOpponent.push(
					{
						notes: notesOpponent,

						cameraFocusThis: !section.mustHitSection
					}
				);

				sectionsPlayer.push(
					{
						notes: notesPlayer,

						cameraFocusThis: section.mustHitSection
					}
				);
			}

			formattedJson.grids.push(
				{
					sections: sectionsOpponent,
					
					character: json.song.player2,
					type: 'opponent'
				}
			);

			formattedJson.grids.push(
				{
					sections: sectionsPlayer,
					
					character: json.song.player1,
					type: 'player'
				}
			);

			formattedJson.grids.push(
				{
					sections: new Array<Dynamic>(),

					character: json.song.gfVersion,
					type: 'extra'
				}
			);

			for (_ in 0...sectionsOpponent.length - 1)
			{
				formattedJson.grids[2].sections.push(
					{
						notes: new Array<Int>(),
		
						cameraFocusThis: false
					}
				);
			}
		}

		return formattedJson;
	}

	private static function getPsychSong(data:Dynamic):PsychSong
		return cast data;

	public static function resizeGame(width:Int, height:Int)
	{
		FlxG.initialWidth = width;
		FlxG.initialHeight = height;

		FlxG.resizeGame(width, height);

		FlxG.resizeWindow(width, height);

		Lib.application.window.x = Std.int(Capabilities.screenResolutionX / 2 - Lib.application.window.width / 2);
		Lib.application.window.y = Std.int(Capabilities.screenResolutionY / 2 - Lib.application.window.height / 2);

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
}