package other;

import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.math.FlxRect;

import core.enums.ALECharacterType;

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

    public var downscroll:Bool = false;

    public var scrollSpeed:Float = 1;

    public var scrollTween:FlxTween;

    public var botplay:Bool = false;

    public var character:Character;

    private var characterTimer:FlxTimer = new FlxTimer();

    public function new(character:Character, sections:Array<ALESection>, startPosition:Float = 0)
    {
        super();

        this.character = character;

        characterTimer.onComplete = (_) -> {
            character.finishedIdleTimer = true;
        };

        allNotes = new FlxTypedGroup<Note>();

        add(strums = new FlxTypedGroup<Strum>());
        add(sustains = new FlxTypedGroup<Note>());
        add(notes = new FlxTypedGroup<Note>());

        if (character.type == PLAYER)
            add(splashes = new FlxTypedGroup<Splash>());

        for (i in 0...4)
        {
            var strum:Strum = new Strum(i, character.type);
            strums.add(strum);

            if (character.type == PLAYER)
            {
                var splash:Splash = new Splash(i);
                splashes.add(splash);
                splash.strum = strum;
            }
        }

        for (section in sections)
        {
            for (chartNote in section.notes)
            {
                if (chartNote[0] < startPosition)
                    continue;

                var note:Note = new Note(chartNote[0], chartNote[1], chartNote[2], character.type, NORMAL);

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

                unspawnNotes.push(note);
            }
        }
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

                unspawnIndex++;
            }
        }

        for (strum in strums)
        {
            if (character.type == PLAYER)
            {

            }
        }

        for (sustain in sustains)
        {
            
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

            Note.setNotePosition(note, strum, strum.direction, 0, (note.strumTime - Conductor.songPosition) * scrollSpeed * 0.45);

            for (sustain in note.children)
                Note.setNotePosition(sustain, note, strum.direction, 0, Conductor.stepCrochet * scrollSpeed * 0.45 * note.children.indexOf(sustain));

            if (character.type == PLAYER)
            {
                if (Conductor.songPosition >= note.strumTime && note.state == NEUTRAL)
                    onNoteMiss(note);
            } else {
            if (note.strumTime - Conductor.songPosition <= 0 && note.state == NEUTRAL)
                onNoteHit(note);
            }
            /*
            if (note.strumTime - Conductor.songPosition <= 0 && note.state == NEUTRAL)
                onNoteHit(note);
                */
        }

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
    }

    public function onNoteMiss(note:Note)
    {
        character.finishedIdleTimer = false;
        
        characterTimer.reset(60 / Conductor.bpm);

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
    }

    public function checkNoteHit(note:Note)
    {

    }

    public function onNoteHit(note:Note)
    {
        removeNote(note);
        
        strums.members[note.data].animation.play('hit', true);
        
        if (character.type == PLAYER)
            splashes.members[note.data].animation.play('splash', true);
        
        character.finishedIdleTimer = false;
        
        characterTimer.reset(60 / Conductor.bpm);

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