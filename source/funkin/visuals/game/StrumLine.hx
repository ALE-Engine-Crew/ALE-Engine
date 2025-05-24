package funkin.visuals.game;

import flixel.sound.FlxSound;

import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.math.FlxRect;

import core.enums.ALECharacterType;
import core.enums.Rating;

import core.structures.ALESection;

class StrumLine extends FlxGroup
{
    public var strums:FlxTypedGroup<Strum>;
    public var sustains:FlxTypedGroup<Note>;
    public var notes:FlxTypedGroup<Note>;
    public var allNotes:FlxTypedGroup<Note>;

    public var unspawnIndex:Int = 0;
    public var unspawnNotes:Array<Note> = [];

    public var splashes:FlxTypedGroup<Splash>;

    public var downScroll:Bool = false;

    public var scrollSpeed:Float = 1;

    public var scrollTween:FlxTween;

    public var botplay:Bool;

    public var character:Character;

    public var noteHitCallback:(Note, Rating) -> Void;
    public var noteMissCallback:Note -> Void;
    public var noteSpawnCallback:Note -> Void;

    public var voices:Array<FlxSound> = [];

    public function new(character:Character, chartNotes:Array<Array<Dynamic>>, startPosition:Float)
    {
        super();

        this.character = character;

        this.downScroll = ClientPrefs.data.downScroll;

        botplay = this.character.type != PLAYER;

        allNotes = new FlxTypedGroup<Note>();

        add(strums = new FlxTypedGroup<Strum>());
        add(sustains = new FlxTypedGroup<Note>());
        add(notes = new FlxTypedGroup<Note>());

        add(splashes = new FlxTypedGroup<Splash>());

        for (i in 0...4)
        {
            var strum:Strum = new Strum(i, character.type, this);
            strums.add(strum);

            var splash:Splash = new Splash(i);
            splashes.add(splash);
            splash.strum = strum;
        }

        for (chartNote in chartNotes)
        {
            if (chartNote[0] < startPosition)
                continue;

            var note:Note = new Note(chartNote[0], chartNote[1], chartNote[2], chartNote[3], character.type, NORMAL);

            /*
            var length:Float = chartNote[2];

            if (length > 0)
            {
                var parent:Note = note;

                var rawLoop:Float = length / Conductor.stepCrochet;

                var susLoop:Int = rawLoop - Math.floor(rawLoop) <= 0.8 ? Math.floor(rawLoop) : Math.round(rawLoop);

                if (susLoop <= 0)
                    susLoop = 1;

                for (i in 0...susLoop + 1)
                {
                    var sustain:Note = new Note(chartNote[0], chartNote[1], chartNote[2], character.type, i == susLoop ? SUSTAIN_END : SUSTAIN);

                    unspawnNotes.push(sustain);

                    note.children.push(sustain);

                    parent = sustain;
                }
            }
            */

            unspawnNotes.push(note);
        }

        unspawnNotes.sort(sortByTime);

        visible = character.type != EXTRA;
    }

    public var spawnTime:Int = 2000;

    public var despawnTime:Int = 300;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (unspawnIndex < unspawnNotes.length)
        {
            var uNote:Note = unspawnNotes[unspawnIndex];

            var spawnT:Float = spawnTime;

            if (scrollSpeed < 1)
                spawnT /= scrollSpeed;

            if (uNote.strumTime - Conductor.songPosition <= spawnT)
            {
                uNote.y = FlxG.height * 4;
                uNote.spawned = true;

                addNote(uNote);

                if (noteSpawnCallback != null)
                    noteSpawnCallback(uNote);

                unspawnIndex++;
            }
        }

        for (note in allNotes)
        {
            if (Conductor.songPosition >= note.strumTime + note.noteLenght + Conductor.stepCrochet + despawnTime / scrollSpeed)
            {
                if (note.state == NEUTRAL)
                    onNoteMiss(note);
                
                note.clipRect = null;

                removeNote(note);
                
                continue;
            }

            note.updateHitbox();
        }

        for (note in notes)
        {
            var strum:Strum = strums.members[note.data];

            Note.setNotePosition(note, strum, strum.direction, 0, (note.strumTime - Conductor.songPosition) * scrollSpeed * 0.45 * (ClientPrefs.data.downScroll ? -1 : 1));

            for (sustain in note.children)
                Note.setNotePosition(sustain, note, strum.direction, 0, Conductor.stepCrochet * scrollSpeed * 0.45 * note.children.indexOf(sustain) * (ClientPrefs.data.downScroll ? -1 : 1));
        
            if (botplay)
            {
                if (Conductor.songPosition >= note.strumTime && note.state == NEUTRAL)
                    onNoteHit(note);
            } else {
                if (Conductor.songPosition - note.strumTime > 175 && note.state == NEUTRAL)
                    onNoteMiss(note);
            }
        }

        if (!botplay)
            useKeys();

        /*
        for (sustain in sustains)
        {
            var parent = sustain.parentNote;

            if (parent != null)
            {
                var strum:Strum = strums.members[sustain.data];

                if (parent.state == HELD)
                {
                    sustain.state = HELD;

                    sustain.sustainHitLenght = Conductor.songPosition - sustain.strumTime;

                    var rect = new FlxRect(0, 0, sustain.frameWidth, sustain.frameHeight);

                    var minSize:Float = sustain.sustainHitLenght - (Conductor.stepCrochet);
                    var maxSize:Float = Conductor.stepCrochet;

                    if (minSize > maxSize)
                        minSize = maxSize;

                    if (minSize > 0)
                        rect.y = (minSize / maxSize) * sustain.frameHeight;

                    sustain.clipRect = rect;

                    var holdPercent:Float = (sustain.sustainHitLenght / parent.noteLenght);

                    if (sustain.state == NEUTRAL || holdPercent >= 1)
                    {
                        sustain.state = RELEASED;

                        if (holdPercent > 0.3)
                        {
                            if (sustain.noteType == SUSTAIN_END)
                                onNoteHit(sustain);

                            sustain.state = HIT;
                        }
                    } else {
                        onNoteMiss(sustain);
                    }
                }

                if (parent.state == LOST && sustain.state != LOST)
                    onNoteMiss(sustain);
            }
        }
        */
    }

    function sortByTime(obj1:Note, obj2:Note):Int
        return FlxSort.byValues(FlxSort.ASCENDING, obj1.strumTime, obj2.strumTime);

    function useKeys():Void
    {
        var keysJustPressed:Array<Bool> = [
            FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.left),
            FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.down),
            FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.up),
            FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.right)
        ];

        var keysJustReleased:Array<Bool> = [
            FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.left),
            FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.down),
            FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.up),
            FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.right)
        ];
        
        var pressedData:Int = -1;

        for (note in notes)
            if (keysJustPressed[note.data] && note.state == NEUTRAL && note.ableToHit)
            {
                pressedData = note.data;

                var difference = Math.abs(note.strumTime - Conductor.songPosition + 22.5);

                var rating:Rating = null;

                if (difference <= 50)
                    rating = SICK;
                else if (difference <= 95)
                    rating = GOOD;
                else if (difference <= 140)
                    rating = BAD;
                else if (difference <= 175)
                    rating = SHIT;

                onNoteHit(note, rating);

                break;
            }
        
        for (strum in strums)
        {
            if (keysJustPressed[strum.data] && strum.data != pressedData)
                strum.animation.play('pressed', true);

            if (keysJustReleased[strum.data])
                strum.animation.play('idle', true);
        }
    }

    public function onNoteMiss(note:Note)
    {
        note.state = LOST;

        if (noteMissCallback != null)
            noteMissCallback(note);

        character.idleTimer = 0;

        character.animation.play('sing' + (switch (note.data)
            {
                case 0:
                    'LEFT';
                case 1:
                    'DOWN';
                case 2:
                    'UP';
                case 3:
                    'RIGHT';
                default:
                    '';
            }) + 'miss',
            true
        );

        for (sound in voices)
            if (sound.volume != 0)
                sound.volume = 0;
    }

    public function onNoteHit(note:Note, ?rating:Rating)
    {
        if (noteHitCallback != null)
            noteHitCallback(note, rating);

        removeNote(note);
        
        strums.members[note.data].animation.play('hit', true);
        
        if (!botplay && rating == SICK)
            splashes.members[note.data].animation.play('splash', true);
        
        character.idleTimer = 0;
        
        character.animation.play('sing' + switch (note.data)
            {
                case 0:
                    'LEFT';
                case 1:
                    'DOWN';
                case 2:
                    'UP';
                case 3:
                    'RIGHT';
                default:
                    '';
            },
            true
        );

        for (sound in voices)
            if (sound.volume != 1)
                sound.volume = 1;
    }

    public function addNote(note:Note)
    {
        allNotes.add(note);

        if (note.noteType == NORMAL)
            notes.add(note);
        else
            sustains.remove(note);
    }

    public function removeNote(note:Note)
    {
        allNotes.remove(note, true);

        if (note.noteType == NORMAL)
            notes.remove(note, true);
        else
            sustains.remove(note, true);
    }
}