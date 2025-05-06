package funkin.visuals.objects;

import flixel.group.FlxGroup;
import flixel.util.FlxSort;

import core.enums.ALECharacterType;

import core.structures.ALESection;

class StrumLine extends FlxGroup
{
    public var sections:Array<ALESection> = [];

    public var type:ALECharacterType;

    public var character:Character;

    public var strums:FlxTypedGroup<StrumNote>;

    public var notes:FlxTypedGroup<Note>;

    public var splashes:FlxTypedGroup<Splash>;

    private var defaultHitCallback:Note -> Void;
    private var defaultLostCallback:Note -> Void;

    public var unspawnNotes:Array<Note> = [];

    override public function new(sections:Null<Array<ALESection>>, type:ALECharacterType, character:Character, defaultHitCallback:Note -> Void, defaultLostCallback:Note -> Void)
    {
        super();

        if (sections != null)
            this.sections = sections;

        this.type = type;

        this.character = character;

        this.defaultHitCallback = defaultHitCallback;

        this.defaultLostCallback = defaultLostCallback;

        strums = new FlxTypedGroup<StrumNote>();
        add(strums);

        notes = new FlxTypedGroup<Note>();
        add(notes);

        splashes = new FlxTypedGroup<Splash>();
        add(splashes);

        for (i in 0...4)
        {
            var strum:StrumNote = new StrumNote(i, type);
            strums.add(strum);

            var splash:Splash = new Splash(i);
            splashes.add(splash);
            splash.strum = strum;

            strum.splash = splash;
        }

        spawnNotes();
    }

    var daBpm:Float = PlayState.SONG.bpm;

    private function spawnNotes()
    {
        for (section in sections)
        {
            for (noteArray in section.notes)
            {
                var strumTime:Float = noteArray[0];
                var noteData:Int = noteArray[1];
                var sustainLength:Float = noteArray[2];
                var strum:StrumNote = strums.members[noteData];

                var note:Note = new Note(type, noteData, strumTime, character, strum);
                note.defaultHitCallback = defaultHitCallback;
                note.defaultLostCallback = defaultLostCallback;
                note.killFunction = function(theNote:Note)
                {
                    notes.remove(theNote, true);
                }
                unspawnNotes.push(note);

                /*
                var curStepCrochet:Float = 60 / daBpm * 1000 / 4;

                final roundSustain:Int = Math.round(sustainLength / Conductor.stepCrochet);

                if (roundSustain > 0)
                {
                    var prevNote:Note = note;
                    
                    for (i in 0...roundSustain)
                    {
                        var isEnd:Bool = i == roundSustain - 1;

                        var sustainNote:Note = new Note(type, noteData, strumTime + (curStepCrochet * i), character, strum, true, prevNote, isEnd);
                        unspawnNotes.push(sustainNote);
                        prevNote = sustainNote;

                        if (prevNote.isSustainNote)
                            prevNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
                    }
                }
                    */
            }
        }

        unspawnNotes.sort(sortByTime);
    }
    
	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

    public var spawnTime:Float = 1500;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (unspawnNotes[0] != null)
        {
            if (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < spawnTime / unspawnNotes[0].scrollSpeed)
            {
                var note:Note = unspawnNotes[0];
                notes.add(note);
                note.spawned = true;

                unspawnNotes.splice(unspawnNotes.indexOf(note), 1);
            }
        }
    }
}