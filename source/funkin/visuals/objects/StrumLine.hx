package funkin.visuals.objects;

import flixel.group.FlxGroup;

import core.enums.ALECharacterType;

import core.structures.ALESection;

class StrumLine extends FlxGroup
{
    public var sections:Array<ALESection> = [];

    public var type:ALECharacterType;

    public var character:Character;

    public var strums:FlxTypedGroup<StrumNote>;

    public var notes:NoteGroup;

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

        for (i in 0...4)
        {
            var strum:StrumNote = new StrumNote(i, type);
            strums.add(strum);
        }

        notes = new NoteGroup();
        add(notes);

        spawnNotes();
    }

    private function spawnNotes()
    {
        var heightFactor:Float = 75;

        for (section in sections)
        {
            for (noteArray in section.notes)
            {
                var strumTime:Float = noteArray[0];
                var noteData:Int = noteArray[1];
                var sustainLength:Float = noteArray[2];
                var strum:StrumNote = strums.members[noteData];

                var note:Note = new Note(type, noteData, strumTime, 0, character, strum);
                note.defaultHitCallback = defaultHitCallback;
                note.defaultLostCallback = defaultLostCallback;
                unspawnNotes.push(note);

                if (sustainLength > 0)
                {
                    var prevNote:Note = note;
                    var steps:Int = Math.floor(sustainLength / heightFactor);

                    for (i in 0...steps)
                    {
                        var isEnd:Bool = i == steps - 1;
                        var sustainNote:Note = new Note(type, noteData, strumTime + (i + 1) * heightFactor, heightFactor, character, strum, true, prevNote, isEnd);
                        unspawnNotes.push(sustainNote);
                        prevNote = sustainNote;
                    }
                }
            }
        }
    }

    public var spawnTime:Float = 2000;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (unspawnNotes[0] != null)
        {
            var time:Float = spawnTime * PlayState.instance.scrollSpeed;

            if (PlayState.instance.scrollSpeed < 1)
                time /= PlayState.instance.scrollSpeed;

            while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
            {
                var note:Note = unspawnNotes[0];
                notes.add(note);
                note.spawned = true;

                unspawnNotes.splice(unspawnNotes.indexOf(note), 1);
            }
        }
    }
}