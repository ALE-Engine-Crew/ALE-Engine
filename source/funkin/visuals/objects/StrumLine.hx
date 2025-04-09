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

    override public function new(sections:Null<Array<ALESection>>, type:ALECharacterType, character:Character)
    {
        super();

        if (sections != null)
            this.sections = sections;

        this.type = type;

        this.character = character;

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

                // Crear nota principal
                var note:Note = new Note(type, noteData, strumTime, 0, character, strum);

                // Crear notas sustain si hay longitud
                if (sustainLength > 0)
                {
                    var prevNote:Note = note;
                    var steps:Int = Math.floor(sustainLength / heightFactor);

                    for (i in 0...steps)
                    {
                        var isEnd:Bool = i == steps - 1;
                        var sustainNote:Note = new Note(type, noteData, strumTime + (i + 1) * heightFactor, heightFactor, character, strum, true, prevNote, isEnd);
                        notes.add(sustainNote);
                        prevNote = sustainNote;
                    }
                }
                
                notes.add(note);
            }
        }
    }
}