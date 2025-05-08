package other;

import utils.ALEParserHelper;

import core.structures.ALESong;
import core.structures.ALEStage;

class ChartState extends ScriptState
{
    public var strumLines:StrumLinesGroup = new StrumLinesGroup();

    public var characters:CharactersGroup = new CharactersGroup();

    public var scrollSpeed(default, set):Float = 1;
    public function set_scrollSpeed(value:Float):Float
    {
        scrollSpeed = value;

        if (strumLines != null)
            for (grp in strumLines.getGroups())
                for (strl in grp)
                    strl.scrollSpeed = scrollSpeed;

        return scrollSpeed;
    }

    public static var SONG:ALESong;
    public static var STAGE:ALEStage;

    override function create()
    {
        super.create();

        add(characters);
        
        var SONG = ALEParserHelper.getALESong(Json.parse(File.getContent(Paths.getPath('songs/Stress/charts/hard.json'))));

        Conductor.bpm = SONG.bpm;
        
        loadScript('script');

        callOnScripts('onCreate');

        STAGE = ALEParserHelper.getALEStage(SONG.stage);

        // loadScript('stages/' + SONG.stage);
        
        add(strumLines);

        FlxG.sound.playMusic(Paths.getPath('songs/Stress/song/Voices.ogg'));

        for (grid in SONG.grids)
        {
            var character = new Character(
                switch (grid.type)
                {
                    case OPPONENT:
                        STAGE.opponentsPosition[characters.opponents.members.length][0];
                    case PLAYER:
                        STAGE.playersPosition[characters.players.members.length][0];
                    case EXTRA:
                        STAGE.extrasPosition[characters.extras.members.length][0];
                },
                switch (grid.type)
                {
                    case OPPONENT:
                        STAGE.opponentsPosition[characters.opponents.members.length][1];
                    case PLAYER:
                        STAGE.playersPosition[characters.players.members.length][1];
                    case EXTRA:
                        STAGE.extrasPosition[characters.extras.members.length][1];
                },
                grid.character, grid.type
            );

            var strl:StrumLine = new StrumLine(character, grid.sections);

            switch (grid.type)
            {
                case PLAYER:
                    characters.players.add(character);

                    strumLines.players.add(strl);
                case OPPONENT:
                    characters.opponents.add(character);

                    strumLines.opponents.add(strl);
                case EXTRA:
                    characters.extras.add(character);

                    strumLines.extras.add(strl);
            }
        }

        scrollSpeed = SONG.speed;

        callOnScripts('onCreatePost');
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        callOnScripts('onUpdatePost', [elapsed]);
    }

    override function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        if (curBeat % 2 == 0)
        {
            for (charGroup in characters.getGroups())
                for (character in charGroup)
                    if (character.finishedIdleTimer)
                        if (character.animation.exists('idle'))
                            character.animation.play('idle');
                        else if (character.animation.exists('danceLeft'))
                            character.animation.play('danceLeft');
        } else if (curBeat % 2 == 1) {
            for (charGroup in characters.getGroups())
                for (character in charGroup)
                    if (character.animation.exists('danceRight') && character.finishedIdleTimer)
                        character.animation.play('danceRight');
        }
    }
}