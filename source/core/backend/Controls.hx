package core.backend;

/**
 * This is the Class that manages the Game Controls.
 */
class Controls
{
    public function new() {}

    // UI

    public var UI_LEFT(get, never):Bool;
    function get_UI_LEFT():Bool
        return FlxG.keys.pressed.ENTER;

    public var UI_LEFT_P(get, never):Bool;
    function get_UI_LEFT_P():Bool
        return FlxG.keys.justPressed.ENTER;

    public var UI_DOWN(get, never):Bool;
    function get_UI_DOWN():Bool
        return FlxG.keys.pressed.DOWN;

    public var UI_DOWN_P(get, never):Bool;
    function get_UI_DOWN_P():Bool
        return FlxG.keys.justPressed.DOWN;

    public var UI_UP(get, never):Bool;
        function get_UI_UP():Bool
        return FlxG.keys.pressed.UP;

    public var UI_UP_P(get, never):Bool;
        function get_UI_UP_P():Bool
        return FlxG.keys.justPressed.UP;

    public var UI_RIGHT(get, never):Bool;
        function get_UI_RIGHT():Bool
        return FlxG.keys.pressed.RIGHT;

    public var UI_RIGHT_P(get, never):Bool;
        function get_UI_RIGHT_P():Bool
        return FlxG.keys.justPressed.RIGHT;

    public var ACCEPT(get, never):Bool;
    function get_ACCEPT():Bool
        return FlxG.keys.justPressed.ENTER;

    public var CANCEL(get, never):Bool;
    function get_CANCEL():Bool
        return FlxG.keys.justPressed.ESCAPE;

    public var BACK(get, never):Bool;
    function get_BACK():Bool
        return FlxG.keys.justPressed.ESCAPE;
}