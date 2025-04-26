package other;

import utils.ALEParserHelper;

import core.structures.ALESong;

class ChartState extends MusicBeatState
{
    public var strumLines:FlxTypedGroup<StrumLine> = new FlxTypedGroup<StrumLine>();

    override function create()
    {
        super.create();

        add(strumLines);
        
        var json:ALESong = ALEParserHelper.getALESong(Json.parse(File.getContent(Paths.getPath('songs/Stress/charts/hard.json'))));

        for (grid in json.grids)
        {
            var strl:StrumLine = new StrumLine(grid.type, grid.sections);
            strumLines.add(strl);
        }
    }
}