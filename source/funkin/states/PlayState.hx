package funkin.states;

import flixel.FlxObject;

import core.structures.*;

import funkin.visuals.objects.StrumLine;
import funkin.visuals.objects.Character;

#if mobile
import funkin.visuals.objects.StrumControl;
#end

import openfl.events.KeyboardEvent;

class PlayState extends ScriptState
{
    public static var instance:PlayState;

    public static var SONG:ALESong;

    public var STAGE:ALEStage;

    public static var startPosition:Float = 0;

    public var scrollSpeed(default, set):Float = 1;

    function set_scrollSpeed(value:Float):Float
    {
        scrollSpeed = value;

        if (strumLines != null)
            for (strumLine in strumLines)
                for (strum in strumLine.strums)
                    strum.scrollSpeed = scrollSpeed;

        return scrollSpeed;
    }

    public var botplay(default, set):Bool = false;

    function set_botplay(value:Bool):Bool
    {
        botplay = value;

        if (strumLines != null)
            for (strumLine in strumLines)
                for (strum in strumLine.strums)
                    strum.botplay = botplay;

        return botplay;
    }

    public var voices:FlxSound;

    public var strumLines:FlxTypedGroup<StrumLine>;

    public var characters:FlxTypedGroup<Character>;

    public static var songRoute:String = '';

	var camPos:FlxObject;

    private var cameraSections:Array<Character> = [];

    public var cameraZoom:Float = 1;

    #if mobile
    private var mobileControlsCamera:FlxCamera;
    #end

    override function create()
    {
        super.create();

        if (Paths.fileExists(songRoute + '/scripts'))
            for (file in FileSystem.readDirectory(Paths.getPath(songRoute + '/scripts')))
                loadScript(songRoute + '/scripts/' + file);

        if (Paths.fileExists('scripts/songs'))
            for (file in FileSystem.readDirectory(Paths.getPath('scripts/songs')))
                loadScript('scripts/songs/' + file);

        STAGE = returnALEStage(SONG.stage);

        loadScript('stages/' + SONG.stage);

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);
		
		camGame.target = camPos;
		camGame.followLerp = 2.4 * STAGE.cameraSpeed;
        cameraZoom = STAGE.cameraZoom;

        instance = this;
        
        callOnScripts('onCreate');

        Conductor.bpm = SONG.bpm;

        spawnGrids();

        scrollSpeed = SONG.speed;

        moveCamera();

		FlxG.sound.music = Paths.inst();
		FlxG.sound.music.play();

		FlxG.sound.music.volume = 0.6;

		voices = Paths.voices();
		voices.play();

		FlxG.sound.list.add(voices);

		FlxG.sound.music.time = voices.time = startPosition;

        #if desktop
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        #elseif mobile
		mobileControlsCamera = new FlxCamera();
		mobileControlsCamera.bgColor = FlxColor.TRANSPARENT;
        
		FlxG.cameras.add(mobileControlsCamera, false);

        for (i in 0...4)
        {
            var ctrl:StrumControl = new StrumControl(i, hitNote, releaseNote);
            add(ctrl);
            ctrl.cameras = [mobileControlsCamera];
        }
        #end

        callOnScripts('onCreatePost');
    }

	var keyPressed:Array<Int> = [];

	function onKeyPress(event:KeyboardEvent)
	{
		if (botplay || keyPressed.contains(event.keyCode))
			return;

		switch (event.keyCode)
		{
			case 68:
				hitNote(0);
			case 70:
				hitNote(1);
			case 74:
				hitNote(2);
			case 75:
				hitNote(3);
		}

		keyPressed.push(event.keyCode);
	}

	function onKeyRelease(event:KeyboardEvent)
	{
		if (botplay || !keyPressed.contains(event.keyCode))
			return;

		var allowedKeys:Array<Int> = [68, 70, 74, 75];

		if (!allowedKeys.contains(event.keyCode))
			return;
        
        releaseNote(allowedKeys.indexOf(event.keyCode));

		keyPressed.remove(event.keyCode);
	}

	function hitNote(id:Int)
	{
		for (strumLine in strumLines)
		{
            if (strumLine.type == PLAYER)
            {
                for (note in strumLine.notes)
                {
                    if (id == note.noteData && note.ableToHit && !note.isSustainNote)
                    {
                        note.hitFunction();
        
                        return;
                    }
                }

                strumLine.strums.members[id].sprite.animation.play('pressed', true);
            }
		}
	}

    function releaseNote(id:Int)
    {
		for (strumLine in strumLines)
            if (strumLine.type == PLAYER)
                strumLine.strums.members[id].sprite.animation.play('idle', true);
    }

    private function spawnGrids()
    {
        characters = new FlxTypedGroup<Character>();
        add(characters);

        strumLines = new FlxTypedGroup<StrumLine>();
        add(strumLines);
        strumLines.cameras = [camHUD];

        var extras:Array<Character> = [];
        var opponents:Array<Character> = [];
        var players:Array<Character> = [];

        var extraStrums:Array<StrumLine> = [];
        var opponentStrums:Array<StrumLine> = [];
        var playerStrums:Array<StrumLine> = [];

        var camMaps:Map<Int, Character> = [];

        for (num => grid in SONG.grids)
        {
            var character = new Character(grid.character, grid.type,
                switch (grid.type)
                {
                    case OPPONENT: opponents.length;
                    case PLAYER: players.length;
                    case EXTRA: extras.length;
                }
            );

            var strumLine:StrumLine = new StrumLine(grid.sections, grid.type, character);

            for (index => section in grid.sections)
                if (section.cameraFocusThis)
                    camMaps.set(index, character);

            switch (grid.type)
            {
                case EXTRA:
                    character.setPosition(STAGE.extrasPosition[extras.length][0], STAGE.extrasPosition[extras.length][1]);

                    extras.push(character);

                    extraStrums.push(strumLine);
                case OPPONENT:
                    character.setPosition(STAGE.opponentsPosition[opponents.length][0], STAGE.opponentsPosition[opponents.length][1]);

                    opponents.push(character);
                    
                    opponentStrums.push(strumLine);
                case PLAYER:
                    character.setPosition(STAGE.playersPosition[players.length][0], STAGE.playersPosition[players.length][1]);

                    players.push(character);
                    
                    playerStrums.push(strumLine);
            }
        }

        for (i in 0...[for (k in camMaps.keys()) k].length)
            cameraSections.push(camMaps.get(i));

        for (character in extras)
            characters.add(character);

        extras = [];

        for (character in opponents)
            characters.add(character);

        opponents = [];

        for (character in players)
            characters.add(character);

        players = [];

        for (strum in extraStrums)
            strumLines.add(strum);

        extraStrums = [];

        for (strum in opponentStrums)
            strumLines.add(strum);

        opponentStrums = [];

        for (strum in playerStrums)
            strumLines.add(strum);

        playerStrums = [];
    }

    override function beatHit()
    {
        super.beatHit();

        setOnScripts('curBeat', curBeat);
        callOnScripts('onBeatHit');

        if (curBeat % 2 == 0)
        {
            for (character in characters)
            {
                if (character.idleTimer >= 60 / Conductor.bpm)
                {
                    if (character.animation.exists('idle'))
                        character.animation.play('idle', true);
                    else if (character.animation.exists('danceLeft'))
                        character.animation.play('danceLeft', true);
                }
            }
        } else if (curBeat % 2 == 1) {
            for (character in characters)
                if (character.animation.exists('danceRight') && character.idleTimer >= 60 / Conductor.bpm)
                    character.animation.play('danceRight');
        }
    }

    override function sectionHit()
    {
        super.sectionHit();

        camGame.zoom += 0.03;
        camHUD.zoom += 0.015;

        moveCamera();

        setOnScripts('curSection', curSection);
        callOnScripts('onSectionHit');
    }

    function moveCamera()
    {
        if (cameraSections[curSection] != null)
        {
            var curChar:Character = cameraSections[curSection];
    
            camPos.x = curChar.getMidpoint().x + curChar.cameraOffset[0];
            camPos.y = curChar.getMidpoint().y + curChar.cameraOffset[1];
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, cameraZoom, 0.1);
        camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.1);

        if (FlxG.keys.justPressed.R)
            FlxG.resetState();

        if (FlxG.keys.justPressed.B)
            botplay = !botplay;

        if (characters != null)
            for (character in characters)
                if (character.idleTimer < 60 / Conductor.bpm)
                    character.idleTimer += elapsed;

        callOnScripts('onUpdatePost', [elapsed]);
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

    override public function destroy()
    {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		
        destroyScripts();

        super.destroy();
    }

	function returnALEStage(path:Dynamic):ALEStage
	{
        if (Paths.fileExists('stages/' + path + '.json'))
        {
            var data:Dynamic = Json.parse(File.getContent(Paths.getPath('stages/' + path + '.json')));

            if (data.format == 'ale-format-v0.1')
            {
                return cast data;
            } else {
                var formattedStage:ALEStage = {
                    opponentsPosition: data.opponent == null ? [[0, 0]] : [data.opponent],
                    playersPosition: data.boyfriend == null ? [[0, 0]] : [data.boyfriend],
                    extrasPosition: data.girlfriend == null ? [[0, 0]] : [data.girlfriend],
    
                    opponentsCamera: data.camera_opponent == null ? [[0, 0]] : [data.camera_opponent],
                    playersCamera: data.camera_boyfriend == null ? [[0, 0]] : [data.camera_boyfriend],
                    extrasCamera: data.camera_girlfriend == null ? [[0, 0]] : [data.camera_girlfriend],
    
                    format: 'ale-format-v0.1',
    
                    cameraZoom: data.defaultZoom == null ? 1 : data.defaultZoom,
                    cameraSpeed: data.camera_speed == null ? 1 : data.camera_speed
                };
    
                return cast formattedStage;
            }
        } else {
            return cast {
                opponentsPosition: [[0, 0]],
                playersPosition: [[0, 0]],
                extrasPosition: [[0, 0]],

                opponentsCamera: [[0, 0]],
                playersCamera: [[0, 0]],
                extrasCamera: [[0, 0]],

                format: 'ale-format-v0.1',

                cameraZoom: 1,
                cameraSpeed: 1
            }
        }
	}
}