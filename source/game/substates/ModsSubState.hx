package game.substates;

class ModsSubState extends MusicBeatSubState
{
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) close();
    }
}