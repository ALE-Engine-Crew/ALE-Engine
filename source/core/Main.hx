package core;

import lime.app.Application;

#if android
import android.content.Context;
#end

import haxe.io.Path;

import flixel.FlxGame;
import openfl.display.Sprite;

import core.config.MainState;
import core.config.CopyState;

import openfl.Lib;
import openfl.events.Event;

import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;

import openfl.Lib;

#if (windows && cpp)
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end

#if linux
import lime.graphics.Image;

@:cppInclude('./cpp/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	@:allow(utils.CoolUtil)
	private static var game = {
		width: 1280,
		height: 720,
		initialState: #if android CopyState #else MainState #end,
		zoom: -1.0,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static function main():Void
	{
		Lib.current.addChild(new Main());

		Lib.application.window.onClose.add(function()
			{
				ClientPrefs.savePrefs();
			}
		);
	}

	public function new()
	{
		super();

		#if (windows && cpp)
		untyped __cpp__("SetProcessDPIAware();");

		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		#end

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
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

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

		#if LUA_ALLOWED
		llua.Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(scripting.lua.LuaCallbackHandler.call));
		#end

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		
		#if linux
		Lib.current.stage.window.setIcon(Image.fromFile('icon.png'));
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		FlxG.signals.gameResized.add(function (width:Float, height:Float)
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
	
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
	
		#if (windows && cpp)
		cpp.WindowsCPP.showMessageBox('ALE Engine | Crash Handler', errMsg, ERROR);
		#else
		Application.current.window.alert(errMsg, 'ALE Engine | Crash Handler');
		#end

		Sys.println(errMsg);

		Sys.exit(1);
	}
}
