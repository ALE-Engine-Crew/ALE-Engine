package other;

import flixel.group.FlxGroup;
import flixel.util.FlxSort;

import core.enums.ALECharacterType;

import core.structures.ALESection;

class StrumLine extends FlxGroup
{
    public var type:ALECharacterType;

    public var strums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();

    public var notes:NoteGroup = new NoteGroup();

    public var unspawnNotes:Array<Note> = [];

    public var sections:Array<ALESection> = [];
    
    override public function new(type:ALECharacterType, sections:Array<ALESection>)
    {
        super();

        this.type = type;

        this.sections = sections;

        add(strums);

        for (i in 0...4)
        {
            var strum:StrumNote = new StrumNote(type, i);
            strums.add(strum);
        }

        add(notes);

        spawnNotes();
    }

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

                var note:Note = new Note(noteData, strumTime, strum);

                unspawnNotes.push(note);
            }
        }

        unspawnNotes.sort(sortByTime);
    }
    
	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

    public var spawnTime:Float = 2000;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (unspawnNotes[0] != null)
        {
            var time:Float = spawnTime;

            while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
            {
                var note:Note = unspawnNotes[0];
                notes.add(note);
                note.spawned = true;
                note.updatePosition();

                note.customKillFunction = () -> {
                    notes.remove(note, true);
                };

                unspawnNotes.splice(unspawnNotes.indexOf(note), 1);
            }
        }
    }
}