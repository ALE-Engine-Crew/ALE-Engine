package funkin.debug;

import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

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
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPressed);
        else
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPressed);

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

    function onKeyPressed(event:KeyboardEvent)
    {
        if (event.keyCode == Keyboard.F3)
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

	private var spriteOffset:Float = 0;

	private function addField(sprite:DebugField, ?pushCategory:Bool = true)
    {
		sprite.y = spriteOffset;

		addChild(sprite);

        if (pushCategory)
            categories.push(sprite);

        sprite.updateField();

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
        
        instance = null;
    }
}