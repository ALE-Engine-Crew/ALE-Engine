package other;

import utils.ALEParserHelper;

import funkin.visuals.objects.Character;

import core.structures.ALESong;

class ChartState extends ScriptState
{
    public var strumLines:StrumLinesGroup = new StrumLinesGroup();

    var SONG:ALESong;

    override function create()
    {
        super.create();
        
        loadScript('script');

        callOnScripts('onCreate');
        
        add(strumLines);

        FlxG.sound.playMusic(Paths.getPath('songs/Stress/song/Voices.ogg'));
        
        var SONG = ALEParserHelper.getALESong(Json.parse(File.getContent(Paths.getPath('songs/Stress/charts/hard.json'))));

        for (grid in SONG.grids)
        {
            var strl:StrumLine = new StrumLine(new Character(grid.character, grid.type, SONG.grids.indexOf(grid)), grid.sections);

            switch (grid.type)
            {
                case PLAYER:
                    strumLines.players.add(strl);
                case OPPONENT:
                    strumLines.opponents.add(strl);
                case EXTRA:
                    strumLines.extras.add(strl);
            }
        }

        callOnScripts('onCreatePost');
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        callOnScripts('onUpdatePost', [elapsed]);
    }
}