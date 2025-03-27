package core;

#if android
import android.content.Context;
#end

#if linux
@:cppInclude('./cpp/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

import haxe.io.Path;

import flixel.FlxGame;
import openfl.display.Sprite;

import core.config.MainState;
import core.config.CopyState;

import openfl.Lib;
import openfl.events.Event;

class Main extends Sprite
{
	private var game = {
		width: 1280,
		height: 720,
		initialState: #if android CopyState #else MainState #end,
		zoom: -1.0,
		framerate: 240,
		skipSplash: true,
		startFullscreen: false
	};

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new()
	{
		super();

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage == null)
			addEventListener(Event.ADDED_TO_STAGE, init);
		else
			init();
	}

	private function init(?event:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			#if mobile
			game.zoom = 1.0;
			#else
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;

			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
			#end
		}

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		
		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		FlxG.signals.gameResized.add(
			function (width:Float, height:Float)
			{
				if (FlxG.cameras != null)
				{
					for (cam in FlxG.cameras.list)
					{
						if (cam != null && cam.filters != null)
						{
							resetSpriteCache(cam.flashSprite);
						}
					}
				}

				if (FlxG.game != null)
					resetSpriteCache(FlxG.game);
	   		}
	   );
	}
	
	private static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess
		{
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}
