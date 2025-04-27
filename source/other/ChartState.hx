package other;

import utils.ALEParserHelper;

import core.structures.ALESong;

class ChartState extends ScriptState
{
    public var strumLines:FlxTypedGroup<StrumLine> = new FlxTypedGroup<StrumLine>();

    override function create()
    {
        super.create();

        add(strumLines);

        FlxG.sound.playMusic(Paths.getPath('songs/Stress/song/Voices.ogg'));
        
        var json:ALESong = ALEParserHelper.getALESong(Json.parse(File.getContent(Paths.getPath('songs/Stress/charts/hard.json'))));

        for (grid in json.grids)
        {
            if (grid.type == EXTRA)
                continue;

            var strl:StrumLine = new StrumLine(grid.type, grid.sections);
            strumLines.add(strl);
        }

        for (strl in strumLines)
            for (str in strl.strums)
                str.scrollSpeed = json.speed;

        loadScript('script');

        callOnScripts('onCreate');
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);
    }
}