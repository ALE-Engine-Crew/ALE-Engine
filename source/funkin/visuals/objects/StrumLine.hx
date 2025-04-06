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
        for (section in sections)
        {
            for (noteArray in section.notes)
            {
                var note:Note = new Note(type, noteArray[1], noteArray[0], noteArray[2], character, strums.members[noteArray[1]]);
                notes.add(note);
            }
        }
    }
}