package core.backend;

import core.structures.UIControls;
import core.structures.NotesControls;
import core.structures.EngineControls;

/**
 * This is the Class that manages the Game Controls.
 */
class Controls
{
    public function new() {}

    // Notes

    @:unreflective var notes:NotesControls = ClientPrefs.data.controls.notes;

    public var NOTE_LEFT(get, never):Bool;
    function get_NOTE_LEFT():Bool
        return FlxG.keys.anyPressed(notes.left);

    public var NOTE_LEFT_P(get, never):Bool;
    function get_NOTE_LEFT_P():Bool
        return FlxG.keys.anyJustPressed(notes.left);

    public var NOTE_LEFT_R(get, never):Bool;
    function get_NOTE_LEFT_R():Bool
        return FlxG.keys.anyJustReleased(notes.left);

    public var NOTE_DOWN(get, never):Bool;
    function get_NOTE_DOWN():Bool
        return FlxG.keys.anyPressed(notes.down);

    public var NOTE_DOWN_P(get, never):Bool;
    function get_NOTE_DOWN_P():Bool
        return FlxG.keys.anyJustPressed(notes.down);

    public var NOTE_DOWN_R(get, never):Bool;
    function get_NOTE_DOWN_R():Bool
        return FlxG.keys.anyJustReleased(notes.down);

    public var NOTE_UP(get, never):Bool;
        function get_NOTE_UP():Bool
        return FlxG.keys.anyPressed(notes.up);

    public var NOTE_UP_P(get, never):Bool;
        function get_NOTE_UP_P():Bool
        return FlxG.keys.anyJustPressed(notes.up);

    public var NOTE_UP_R(get, never):Bool;
    function get_NOTE_UP_R():Bool
        return FlxG.keys.anyJustReleased(notes.up);

    public var NOTE_RIGHT(get, never):Bool;
    function get_NOTE_RIGHT():Bool
        return FlxG.keys.anyPressed(notes.right);

    public var NOTE_RIGHT_P(get, never):Bool;
    function get_NOTE_RIGHT_P():Bool
        return FlxG.keys.anyJustPressed(notes.right);

    public var NOTE_RIGHT_R(get, never):Bool;
    function get_NOTE_RIGHT_R():Bool
        return FlxG.keys.anyJustReleased(notes.right);

    // UI
    
    @:unreflective var ui:UIControls = ClientPrefs.data.controls.ui;

    public var UI_LEFT(get, never):Bool;
    function get_UI_LEFT():Bool
        return FlxG.keys.anyPressed(ui.left);

    public var UI_LEFT_P(get, never):Bool;
    function get_UI_LEFT_P():Bool
        return FlxG.keys.anyJustPressed(ui.left);

    public var UI_LEFT_R(get, never):Bool;
    function get_UI_LEFT_R():Bool
        return FlxG.keys.anyJustReleased(ui.left);

    public var UI_DOWN(get, never):Bool;
    function get_UI_DOWN():Bool
        return FlxG.keys.anyPressed(ui.down);

    public var UI_DOWN_P(get, never):Bool;
    function get_UI_DOWN_P():Bool
        return FlxG.keys.anyJustPressed(ui.down);

    public var UI_DOWN_R(get, never):Bool;
    function get_UI_DOWN_R():Bool
        return FlxG.keys.anyJustReleased(ui.down);

    public var UI_UP(get, never):Bool;
        function get_UI_UP():Bool
        return FlxG.keys.anyPressed(ui.up);

    public var UI_UP_P(get, never):Bool;
        function get_UI_UP_P():Bool
        return FlxG.keys.anyJustPressed(ui.up);

    public var UI_UP_R(get, never):Bool;
    function get_UI_UP_R():Bool
        return FlxG.keys.anyJustReleased(ui.up);

    public var UI_RIGHT(get, never):Bool;
    function get_UI_RIGHT():Bool
        return FlxG.keys.anyPressed(ui.right);

    public var UI_RIGHT_P(get, never):Bool;
    function get_UI_RIGHT_P():Bool
        return FlxG.keys.anyJustPressed(ui.right);

    public var UI_RIGHT_R(get, never):Bool;
    function get_UI_RIGHT_R():Bool
        return FlxG.keys.anyJustReleased(ui.right);

    public var ACCEPT(get, never):Bool;
    function get_ACCEPT():Bool
        return FlxG.keys.anyJustPressed(ui.accept);

    public var BACK(get, never):Bool;
    function get_BACK():Bool
        return FlxG.keys.anyJustPressed(ui.back);

    public var MOUSE_WHEEL_DOWN(get, never):Bool;
    function get_MOUSE_WHEEL_DOWN():Bool
        return FlxG.mouse.wheel < 0;

    public var MOUSE_WHEEL_UP(get, never):Bool;
    function get_MOUSE_WHEEL_UP():Bool
        return FlxG.mouse.wheel > 0;

    public var MOUSE_WHEEL(get, never):Bool;
    function get_MOUSE_WHEEL():Bool
        return FlxG.mouse.wheel != 0;

    public var MOUSE(get, never):Bool;
    function get_MOUSE():Bool
        return FlxG.mouse.pressed;
    
    public var MOUSE_P(get, never):Bool;
    function get_MOUSE_P():Bool
        return FlxG.mouse.justPressed;

    public var MOUSE_R(get, never):Bool;
    function get_MOUSE_R():Bool
        return FlxG.mouse.justReleased;
}