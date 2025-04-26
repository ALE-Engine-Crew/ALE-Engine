package other;

import flixel.group.FlxGroup;
import flixel.util.FlxSort;

import core.enums.ALECharacterType;

import core.structures.ALESection;

class StrumLine extends FlxGroup
{
    public var strums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();

    public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

    public var unspawnNotes:Array<Note> = [];
    
    override public function new(type:ALECharacterType, notes:Array<ALESection>)
    {
        super();

        add(strums);

        for (i in 0...4)
        {
            var strum:StrumNote = new StrumNote(type, i);
            strums.add(strum);
        }

        add(notes);
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

                var note:Note = new Note(type, noteData, strumTime, character, strum);
                note.defaultHitCallback = defaultHitCallback;
                note.defaultLostCallback = defaultLostCallback;

                note.killFunction = function(theNote:Note)
                    notes.remove(theNote, true);

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