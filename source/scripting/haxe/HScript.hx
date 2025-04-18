package scripting.haxe;

#if HSCRIPT_ALLOWED
import cpp.*;

import haxe.ds.StringMap;

import tea.SScript;
import tea.SScript.TeaCall;

import core.enums.ScriptType;

class HScript extends SScript
{
	public var type:ScriptType;

	override public function new(file:String, type:ScriptType)
	{
		super(file);

		this.type = type;

		preset();
	}

    override public function preset()
    {
		super.preset();

        var presetClasses:Array<Dynamic> = [
            // Flixel
            flixel.FlxG,
            flixel.math.FlxMath,
            flixel.FlxSprite,
            flixel.text.FlxText,
            flixel.FlxCamera,
            flixel.util.FlxTimer,
            flixel.tweens.FlxTween,
            flixel.tweens.FlxEase,
            flixel.addons.display.FlxRuntimeShader,
            flixel.effects.FlxFlicker,
            flixel.addons.display.FlxBackdrop,
            flixel.addons.editors.ogmo.FlxOgmo3Loader,
            flixel.tile.FlxTilemap,
			flixel.group.FlxGroup,
			flixel.group.FlxGroup.FlxTypedGroup,

            // Haxe
            StringTools,
            sys.io.Process,
			haxe.ds.StringMap,

            // OpenFL
            openfl.Lib,
            sys.io.File,
            openfl.filters.ShaderFilter,

            // ALE
            Paths,
            CoolUtil,
            CoolVars,
			ClientPrefs,
            Conductor,
            core.backend.MusicBeatState,
            CustomState,
			CustomSubState,
			funkin.visuals.objects.Alphabet
        ];

        for (theClass in presetClasses)
            setClass(theClass);

		var instanceVariables:StringMap<Dynamic> = new StringMap<Dynamic>();
		
		if (type == STATE)
		{
			instanceVariables = [
				'game' => FlxG.state,
				'add' => FlxG.state.add,
				'insert' => FlxG.state.insert,
				'controls' => ScriptState.instance.controls,
				'openSubState' => FlxG.state.openSubState,
				'debugPrint' => ScriptState.instance.debugPrint
			];
		} else if (type == SUBSTATE) {
			instanceVariables = [
				'game' => FlxG.state.subState,
				'add' => FlxG.state.subState.add,
				'insert' => FlxG.state.subState.insert,
				'controls' => ScriptSubState.instance.controls,
				'close' => FlxG.state.subState.close,
				'debugPrint' => ScriptSubState.instance.debugPrint
			];
		}

		for (insVar in instanceVariables.keys())
			set(insVar, instanceVariables.get(insVar));

		var presetVariables:StringMap<Dynamic> = [
			'FlxColor' => FlxColorClass,
			'Json' => utils.ALEJson,
		];

		for (preVar in presetVariables.keys())
			set(preVar, presetVariables.get(preVar));

		var presetFunctions:StringMap<Dynamic> = [
			'setWindowBorderColor' => function(r:Int, g:Int, b:Int)
			{
				#if (windows && cpp)
				WindowsCPP.reDefineMainWindowTitle(lime.app.Application.current.window.title);
				WindowsCPP.setWindowBorderColor(r, g, b);
				#end
			},
			'showConsole' => function()
			{
				#if (windows && cpp)
				WindowsTerminalCPP.allocConsole();
				#end
			}
		];

		for (preFunc in presetFunctions.keys())
			set(preFunc, presetFunctions.get(preFunc));
    }

	override public function call(func:String, ?args:Array<Dynamic>):TeaCall
	{
		if (!exists(func))
			return null;

		var callValue:TeaCall = super.call(func, args);

		if (!callValue.succeeded)
		{
			var errorString:String = 'Error: ' + callValue.calledFunction + ' - ' + callValue.exceptions[0].message;
			
			if (type == STATE)
				ScriptState.instance.debugPrint(errorString, FlxColor.RED);
			else if (type == SUBSTATE)
				ScriptSubState.instance.debugPrint(errorString, FlxColor.RED);
		}

		if (callValue != null)
			return callValue;

		return null;
	}
}

class FlxColorClass
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int 
	{
		return cast FlxColor.fromInt(Value);
	}

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}
#end