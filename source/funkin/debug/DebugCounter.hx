package funkin.debug;

import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

import core.structures.EngineControls;

class DebugCounter extends Sprite implements IFlxDestroyable
{
    public static var instance:DebugCounter;

    public var categories:Array<DebugField> = [];

    public var debugMode:Int = 1;

    public var keysEnabled(default, set):Bool = false;

    function set_keysEnabled(value:Bool):Bool
    {
        if (keysEnabled == value)
            return keysEnabled;

        keysEnabled = value;

        if (keysEnabled)
        {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPressed);
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyReleased);
        } else {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPressed);
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyReleased);
        }

        return keysEnabled;
    }

    var fpsCounter:DebugField;

    override public function new()
    {
        super();

        if (instance != null)
            throw 'Can\'t Create Another Instance';

        instance = this;

        x = 10;
        y = 5;

        fpsCounter = new FPSField();
        fpsCounter.enabled = true;
        fpsCounter.bg.alpha = 0;

        addField(fpsCounter, false);

        addField(new ConductorField());
        addField(new FlixelField());
        addField(new SystemField());

        keysEnabled = true;
    }

    var keysPressed:Array<Int> = [];

    var nativeCorrection:Map<String, Int> = [
		"0_64" => FlxKey.INSERT,
		"0_65" => FlxKey.END,
		"0_67" => FlxKey.PAGEDOWN,
		"0_69" => FlxKey.NONE,
		"0_73" => FlxKey.PAGEUP,
		"0_266" => FlxKey.DELETE,
		"123_222" => FlxKey.LBRACKET,
		"125_187" => FlxKey.RBRACKET,
		"126_233" => FlxKey.GRAVEACCENT,
		"0_43" => FlxKey.PLUS,

		"0_80" => FlxKey.F1,
		"0_81" => FlxKey.F2,
		"0_82" => FlxKey.F3,
		"0_83" => FlxKey.F4,
		"0_84" => FlxKey.F5,
		"0_85" => FlxKey.F6,
		"0_86" => FlxKey.F7,
		"0_87" => FlxKey.F8,
		"0_88" => FlxKey.F9,
		"0_89" => FlxKey.F10,
		"0_90" => FlxKey.F11,

		"48_224" => FlxKey.ZERO,
		"49_38" => FlxKey.ONE,
		"50_233" => FlxKey.TWO,
		"51_34" => FlxKey.THREE,
		"52_222" => FlxKey.FOUR,
		"53_40" => FlxKey.FIVE,
		"54_189" => FlxKey.SIX,
		"55_232" => FlxKey.SEVEN,
		"56_95" => FlxKey.EIGHT,
		"57_231" => FlxKey.NINE,

		"48_64" => FlxKey.NUMPADZERO,
		"49_65" => FlxKey.NUMPADONE,
		"50_66" => FlxKey.NUMPADTWO,
		"51_67" => FlxKey.NUMPADTHREE,
		"52_68" => FlxKey.NUMPADFOUR,
		"53_69" => FlxKey.NUMPADFIVE,
		"54_70" => FlxKey.NUMPADSIX,
		"55_71" => FlxKey.NUMPADSEVEN,
		"56_72" => FlxKey.NUMPADEIGHT,
		"57_73" => FlxKey.NUMPADNINE,

		"43_75" => FlxKey.NUMPADPLUS,
		"45_77" => FlxKey.NUMPADMINUS,
		"47_79" => FlxKey.SLASH,
		"46_78" => FlxKey.NUMPADPERIOD,
		"42_74" => FlxKey.NUMPADMULTIPLY
    ];
    
    function correctKey(e:KeyboardEvent):Int
    {
        #if web
        return e.keyCode;
        #else
        var key = nativeCorrection.get(e.charCode + "_" + e.keyCode);
        return key != null ? key : e.keyCode;
        #end
    }
    
    function onKeyPressed(event:KeyboardEvent)
    {
        var key = correctKey(event);
    
        var controls:EngineControls = ClientPrefs.controls.engine;

        if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT)
        {
            if (key == controls.reset_game[0] || key == controls.reset_game[1])
            {
                CoolUtil.resetEngine();
            } else if (key == controls.switch_mod[0] || key == controls.switch_mod[1]) {
                if (FlxG.state.subState == null && !Std.isOfType(FlxG.state, funkin.states.PlayState))
                    CoolUtil.openSubState(new funkin.substates.ModsMenuSubState());
            }
    
            keysPressed.push(key);

            return;
        }
    
        keysPressed.push(key);
    
        if (key == controls.fps_counter[0] || key == controls.fps_counter[1])
            debugMode = (debugMode + 1) % 3;
    
        switch (debugMode)
        {
            case 0:
                fpsCounter.enabled = false;
                for (category in categories)
                    category.enabled = false;
            case 1:
                fpsCounter.enabled = true;
                fpsCounter.bg.alpha = 0;
            case 2:
                fpsCounter.bg.alpha = 0.5;
                for (category in categories)
                    category.enabled = true;
        }
    }
    
    function onKeyReleased(event:KeyboardEvent)
    {
        var key = correctKey(event);
        keysPressed.remove(key);
    }

	private var spriteOffset:Float = 0;

	private function addField(sprite:DebugField, ?pushCategory:Bool = true)
    {
		sprite.y = spriteOffset;

		addChild(sprite);

        if (pushCategory)
            categories.push(sprite);

        sprite.updateField(0);

        spriteOffset += sprite.text.height + sprite.text.y - sprite.title.y + y * 2;
	}

    public function destroy()
    {
        categories = [];

        for (category in categories)
        {
            categories.splice(categories.indexOf(category), 1);

            category = null;
        }
    
        if (parent != null)
            parent.removeChild(this);

        keysEnabled = false;
        
        instance = null;
    }
}