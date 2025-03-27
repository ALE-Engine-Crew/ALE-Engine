package core.backend;

/**
 * The class containing variables related to the game music (FlxG.sound.music)
 */
class Conductor
{
    public static var bpm:Float = 100;

    public static var songLength(get, never):Float;

    private static function get_songLength():Float
        return FlxG.sound.music == null ? 0 : FlxG.sound.music.length;

    public static var songPosition(get, never):Float;

    private static function get_songPosition():Float
        return FlxG.sound.music == null ? 0 : FlxG.sound.music.time;
}