package scripting.lua.flixel;

class LuaText extends LuaPresetBase
{
    public function new(lua)
    {
        super(lua);

        set('newText', function(tag:String, ?x:Float, ?y:Float, ?width:Float, ?text:String, ?size:Int)
            {
                setTag(tag, new FlxText(x, y, width, text, size));
            }
        );

        set('applyTextMarkup', function(tag:String, text:String, rules:Array<Array<Dynamic>>)
            {
                var newRules:Array<FlxTextFormatMarkerPair> = [];

                for (rule in rules)
                    if (rule[0] is Int && rule[1] is String)
                        newRules.push(new FlxTextFormatMarkerPair(new FlxTextFormat(rule[0]), rule[1]));
                    else
                        errorPrint('Rule #' + (rules.indexOf(rule) + 1) + ' is Not [FlxColor, String]');

                if (tagIs(tag, FlxText))
                    getTag(tag).applyMarkup(text, newRules);
            }
        );

        set('setTextFormat', function(tag:String, ?font:String, ?size:Int, ?color:FlxColor, ?alignment:String, ?borderStyle:String, ?borderColor:FlxColor)
            {
                if (tagIs(tag, FlxText))
                    getTag(tag).setFormat(Paths.font(font), size, color, alignment == null ? null : alignmentFromString(alignment), borderStyle == null ? null : borderStyleFromString(borderStyle), borderColor);
            }
        );
    }

    function alignmentFromString(str:String):FlxTextAlign
    {
        var result:FlxTextAlign = switch(str.toUpperCase())
        {
            case 'CENTER': CENTER;
            case 'JUSTIFY': JUSTIFY;
            case 'LEFT': LEFT;
            case 'RIGHT': RIGHT;
            default: null;
        };

        if (result == null)
            errorPrint(str + ' is Not a Text Alignment');

        return result;
    }
    
    function borderStyleFromString(str:String):FlxTextBorderStyle
    {
        var result:FlxTextBorderStyle = switch(str.toUpperCase())
        {
            case 'NONE': NONE;
            case 'SHADOW': SHADOW;
            case 'OUTLINE': OUTLINE;
            case 'OUTLINE_FAST': OUTLINE_FAST;
            default: null;
        };

        if (result == null)
            errorPrint(str + ' is Not a Border Style');

        return result;
    }
}