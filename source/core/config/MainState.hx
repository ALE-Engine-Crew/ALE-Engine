package core.config;

/**
 * Used to configure and add the necessary elements before starting the game
 */
class MainState extends flixel.FlxState
{
    override function create()
    {
        super.create();
    
        CoolVars.engineVersion = lime.app.Application.current.meta.get('version');

		CoolUtil.loadSong('stress', 'hard');

        //MusicBeatState.switchState(new CustomState('introState'));
    }
}