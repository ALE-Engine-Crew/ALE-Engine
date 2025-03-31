package funkin.states;

import core.structures.*;

import funkin.visuals.objects.StrumNote;
import funkin.visuals.objects.Note;
import funkin.visuals.objects.Character;

class PlayState extends ScriptState
{
    public static var instance:PlayState;

    public static var SONG:ALESong;

    public static var startPosition:Float = 0;

    public var scrollSpeed(default, set):Float = 1;

    function set_scrollSpeed(value:Float):Float
    {
        scrollSpeed = value;

        if (playerNotes != null)
            for (note in playerNotes)
                note.scrollSpeed = scrollSpeed;

        if (opponentNotes != null)
            for (note in opponentNotes)
                note.scrollSpeed = scrollSpeed;

        if (extraNotes != null)
            for (note in extraNotes)
                note.scrollSpeed = scrollSpeed;

        return value;
    }

    public var voices:FlxSound;

    public var playerStrums:FlxTypedGroup<StrumNote>;
    public var opponentStrums:FlxTypedGroup<StrumNote>;
    public var extraStrums:FlxTypedGroup<StrumNote>;

    public var playerNotes:FlxTypedGroup<Note>;
    public var opponentNotes:FlxTypedGroup<Note>;
    public var extraNotes:FlxTypedGroup<Note>;

    public var extraCharacters:FlxTypedGroup<Character>;
    public var opponentCharacters:FlxTypedGroup<Character>;
    public var playerCharacters:FlxTypedGroup<Character>;

    public static var songRoute:String = '';

    private var cameraSections:Array<Character>;

    public var cameraZoom:Float = 1;

    override function create()
    {
        super.create();

        if (Paths.fileExists(songRoute + '/scripts'))
            for (file in FileSystem.readDirectory(Paths.getPath(songRoute + '/scripts')))
                loadScript(songRoute + '/scripts/' + file);

        instance = this;
        
        callOnScripts('onCreate');

        Conductor.bpm = SONG.bpm;

        spawnGrids();

		FlxG.sound.music = Paths.inst();
		FlxG.sound.music.play();

		FlxG.sound.music.volume = 0.6;

		voices = Paths.voices();
		voices.play();

		FlxG.sound.list.add(voices);

		FlxG.sound.music.time = voices.time = startPosition;

        callOnScripts('postCreate');
    }

    private function spawnGrids()
    {
        extraCharacters = new FlxTypedGroup<Character>();
        add(extraCharacters);

        opponentCharacters = new FlxTypedGroup<Character>();
        add(opponentCharacters);

        playerCharacters = new FlxTypedGroup<Character>();
        add(playerCharacters);

        extraStrums = new FlxTypedGroup<StrumNote>();
        add(extraStrums);
        extraStrums.cameras = [camHUD];

        extraNotes = new FlxTypedGroup<Note>();
        add(extraNotes);
        extraNotes.cameras = [camHUD];

        opponentStrums = new FlxTypedGroup<StrumNote>();
        add(opponentStrums);
        opponentStrums.cameras = [camHUD];

        opponentNotes = new FlxTypedGroup<Note>();
        add(opponentNotes);
        opponentNotes.cameras = [camHUD];

        playerStrums = new FlxTypedGroup<StrumNote>();
        add(playerStrums);
        playerStrums.cameras = [camHUD];
        
        playerNotes = new FlxTypedGroup<Note>();
        add(playerNotes);
        playerNotes.cameras = [camHUD];

        for (num => grid in SONG.grids)
        {
            var character = new Character(grid.character, grid.type != OPPONENT);

            switch (grid.type)
            {
                case EXTRA:
                    extraCharacters.add(character);
                case OPPONENT:
                    opponentCharacters.add(character);
                case PLAYER:
                    playerCharacters.add(character);
            }

            for (i in 0...4)
            {
                var strum:StrumNote = new StrumNote(i, grid.type);
                
                switch (grid.type)
                {
                    case EXTRA:
                        extraStrums.add(strum);
                    case OPPONENT:
                        opponentStrums.add(strum);
                    case PLAYER:
                        playerStrums.add(strum);
                }
            }

            spawnNotes(grid, character);
        }
    }

    private function spawnNotes(grid:ALEGrid, character:Character)
    {
        for (section in grid.sections)
        {
            for (noteArray in section.notes)
            {
                var note:Note = new Note(grid.type, noteArray[1], noteArray[0], noteArray[2], character,
					switch (grid.type)
					{
						case OPPONENT:
							opponentStrums.members[noteArray[1] + Math.floor((opponentStrums.members.length - 1) / 4) * 4];
						case PLAYER:
							playerStrums.members[noteArray[1] + Math.floor((playerStrums.members.length - 1) / 4) * 4];
						case EXTRA:
                            extraStrums.members[noteArray[1] + Math.floor((extraStrums.members.length - 1) / 4) * 4];
					}
                );
                
                switch (grid.type)
                {
                    case EXTRA:
                        extraNotes.add(note);
                    case OPPONENT:
                        opponentNotes.add(note);
                    case PLAYER:
                        playerNotes.add(note);
                }
            }
        }
    }

    override function beatHit()
    {
        super.beatHit();

        setOnScripts('curBeat', curBeat);
        callOnScripts('onBeatHit');

        if (curBeat % 2 == 0)
        {
            for (character in opponentCharacters)
                character.animation.play('idle', true);

            for (character in playerCharacters)
                character.animation.play('idle', true);

            for (character in extraCharacters)
                character.animation.play('danceLeft');
        } else if (curBeat % 2 == 1) {
            for (character in extraCharacters)
                character.animation.play('danceRight');
        }
    }

    override function sectionHit()
    {
        super.sectionHit();

        setOnScripts('curSection', curSection);
        callOnScripts('onSectionHit');

        camGame.zoom += 0.03;
        camHUD.zoom += 0.015;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, cameraZoom, 0.1);
        camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.1);

        if (FlxG.keys.justPressed.R)
            FlxG.resetState();

        callOnScripts('postUpdate');
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onFocus');

        FlxG.sound.music.play();
        voices.play();
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onFocusLost');

        FlxG.sound.music.pause();
        voices.pause();
    }
}