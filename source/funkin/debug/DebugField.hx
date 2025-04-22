package funkin.debug;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

import openfl.text.TextFormat;
import openfl.text.TextField;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class DebugField extends Sprite implements IFlxDestroyable
{
    public var title:TextField;
    public var text:TextField;

    public var bg:Bitmap;

    public var enabled:Bool = false;

    public function new(?theTitle:String = '', ?titleSize:Int = 18, ?theText:String = '', theTextSize:Int = 14)
    {
        super();

        bg = new Bitmap(new BitmapData(1, 1, 0xFF000000));
        addChild(bg);
        bg.alpha = 0.5;
        bg.x = -DebugCounter.instance.x;
        bg.y = -DebugCounter.instance.y;

        title = new TextField();

        text = new TextField();

		for (field in [title, text])
        {
			field.autoSize = LEFT;
			field.defaultTextFormat = new TextFormat(Paths.font('rajdhani.ttf'), field == this.title ? titleSize : theTextSize, -1);
			field.selectable = false;

			addChild(field);
		}

		title.text = theTitle;
		title.multiline = title.wordWrap = false;
		text.multiline = true;

        text.text = theText;

		text.y = title.y + title.height + 1;

        alpha = 0;
        x = -20;
    }

    override function __enterFrame(time:#if linux Float #else Int #end)
    {
        alpha = CoolUtil.fpsLerp(alpha, enabled ? 1 : 0, 0.25);

        x = CoolUtil.fpsLerp(x, enabled ? 0 : -20, 0.25);

        super.__enterFrame(time);

        if (alpha <= 0.05)
            return;

        updateField();

        bg.scaleX = Math.max(title.width, text.width) + DebugCounter.instance.x * 2;
        bg.scaleY = text.height + text.y - title.y + DebugCounter.instance.y * 2;
    }

    public function updateField():Void {};

    public function destroy()
    {
        if (parent != null)
            parent.removeChild(this);

        for (field in [title, text])
        {
            removeChild(field);

            field.text = '';
        }

        if (bg != null)
        {
            removeChild(bg);
            bg.bitmapData.dispose();
            bg = null;
        }

        title = null;
        text = null;
    }
}