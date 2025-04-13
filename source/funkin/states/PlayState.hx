package funkin.states;

import flixel.FlxObject;

import core.structures.*;

import funkin.visuals.objects.StrumLine;
import funkin.visuals.objects.Character;
import funkin.visuals.objects.Bar;
import funkin.visuals.objects.HealthIcon;

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

		if (botplay)
			scoreTxt.text = 'BOTPLAY';
		else
			scoreTxt.text = 'Disabled BOTPLAY';

        return botplay;
    }

    public var voices:FlxTypedGroup<FlxSound>;

    public var strumLines:FlxTypedGroup<StrumLine>;

    public var characters:FlxTypedGroup<Character>;

    public static var songRoute:String = '';

	var camPos:FlxObject;

    private var cameraSections:Array<Character> = [];

    public var cameraZoom:Float = 1;

    #if mobile
    private var mobileControlsCamera:FlxCamera;
    #end

	var opponentIcon:HealthIcon;
	var playerIcon:HealthIcon;

	public var health(default, set):Float = 50;

	public function set_health(value:Float):Float
	{
		if (value > 100)
			value = 100;

		if (value < 0)
			value = 0;

		health = value;

		if (iconsAnimationFunction != null)
			iconsAnimationFunction();

		return value;
	}

	public var iconsZoomingFunction:Void -> Void;
	public var iconsZoomLerpFunction:Void -> Void;
	public var iconsPositionFunction:Void -> Void;
	public var iconsAnimationFunction:Void -> Void;

    private var opponentIconName:String = '';
    private var playerIconName:String = '';

    private var opponentColor:FlxColor;
    private var playerColor:FlxColor;

	public var healthBar:Bar;

	public var scoreTxt:FlxText;

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

		FlxG.sound.playMusic(Paths.inst());
        FlxG.sound.music.pause();
        FlxG.sound.music.looped = false;
		FlxG.sound.music.volume = 0.6;

		voices = new FlxTypedGroup<FlxSound>();

        loadVoice();
        
        var playerVoices:FlxSound = loadVoice('Player');
        if (playerVoices != null)
            for (player in characters)
                if (player.type == PLAYER)
                    player.voice = playerVoices;
        
        var extraVoices:FlxSound = loadVoice('Extra');
        if (extraVoices != null)
            for (player in characters)
                if (player.type == EXTRA)
                    player.voice = extraVoices;
        
        var opponentVoices:FlxSound = loadVoice('Opponent');
        if (opponentVoices != null)
            for (player in characters)
                if (player.type == OPPONENT)
                    player.voice = opponentVoices;

		FlxG.sound.music.time = startPosition;

        for (voice in voices)
            voice.time = startPosition;

        FlxG.sound.music.play();
        
        for (voice in voices)
            voice.play();

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

		healthBar = new Bar(null, ClientPrefs.data.downscroll ? 75 : FlxG.height - 70);
		add(healthBar);
		healthBar.cameras = [camHUD];
		healthBar.x = FlxG.width / 2 - healthBar.width / 2;
        healthBar.leftColor = opponentColor;
        healthBar.rightColor = playerColor;

		playerIcon = new HealthIcon(playerIconName);
		add(playerIcon);
		playerIcon.flipX = true;
		playerIcon.cameras = [camHUD];
		playerIcon.y = healthBar.y + healthBar.height / 2 - playerIcon.height / 2;

		opponentIcon = new HealthIcon(opponentIconName);
		add(opponentIcon);
		opponentIcon.cameras = [camHUD];
		opponentIcon.y = healthBar.y + healthBar.height / 2 - opponentIcon.height / 2;

		scoreTxt = new FlxText(0, healthBar.y + healthBar.height + 20, FlxG.width, "", 16);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, 'center');
		scoreTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		scoreTxt.borderSize = 1;
		scoreTxt.borderColor = FlxColor.BLACK;
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);
		scoreTxt.cameras = [camHUD];
		scoreTxt.applyMarkup('Score: 0    Misses: 0    Rating: *[N/A]*', [new FlxTextFormatMarkerPair(new FlxTextFormat(CoolUtil.colorFromString('909090')), '*')]);

        iconsZoomingFunction = () -> {
            playerIcon.scale.set(1.2, 1.2);
            playerIcon.updateHitbox();
    
            opponentIcon.scale.set(1.2, 1.2);
            opponentIcon.updateHitbox();
    
            iconsPositionFunction();
        }

        iconsZoomLerpFunction = () -> {
            playerIcon.scale.x = CoolUtil.fpsLerp(playerIcon.scale.x, 1, 0.33);
            playerIcon.scale.y = CoolUtil.fpsLerp(playerIcon.scale.y, 1, 0.33);
            playerIcon.updateHitbox();
    
            opponentIcon.scale.x = CoolUtil.fpsLerp(opponentIcon.scale.x, 1, 0.33);
            opponentIcon.scale.y = CoolUtil.fpsLerp(opponentIcon.scale.y, 1, 0.33);
            opponentIcon.updateHitbox();
        }

        iconsPositionFunction = () -> {
            playerIcon.x = healthBar.x + healthBar.middlePoint - playerIcon.width / 10;
    
            opponentIcon.x = healthBar.x + healthBar.middlePoint - opponentIcon.width + opponentIcon.width / 10;
        }

		iconsAnimationFunction = () -> {
			if (playerIcon != null && playerIcon.animation != null && playerIcon.animation.curAnim != null)
			{
				if (health < 20 && playerIcon.animation.curAnim.curFrame != 1)
				{
					playerIcon.animation.curAnim.curFrame = 1;

					playerIcon.updateHitbox();
				
					playerIcon.y = healthBar.y + healthBar.height / 2 - playerIcon.height / 2;
				}
	
				if (health >= 20 && playerIcon.animation.curAnim.curFrame != 0)
				{
					playerIcon.animation.curAnim.curFrame = 0;

					playerIcon.updateHitbox();
				
					playerIcon.y = healthBar.y + healthBar.height / 2 - playerIcon.height / 2;
				}
			}
	
			if (opponentIcon != null && opponentIcon.animation != null && opponentIcon.animation.curAnim != null)
			{
				if (health > 80 && opponentIcon.animation.curAnim.curFrame != 1)
				{
					opponentIcon.animation.curAnim.curFrame = 1;

					opponentIcon.y = healthBar.y + healthBar.height / 2 - opponentIcon.height / 2;
				}
	
				if (health <= 80 && opponentIcon.animation.curAnim.curFrame != 0)
				{
					opponentIcon.animation.curAnim.curFrame = 0;
					
					opponentIcon.y = healthBar.y + healthBar.height / 2 - opponentIcon.height / 2;
				}
			}
		};


        callOnScripts('onCreatePost');
    }

    private function loadVoice(?prefix:String = ''):FlxSound
    {
        if (Paths.voices(prefix) == null || !SONG.needsVoices)
            return null;
        
        var sound:FlxSound = new FlxSound();
        sound.loadEmbedded(Paths.voices(prefix));
        sound.looped = false;

        voices.add(sound);

		FlxG.sound.list.add(sound);

        return sound;
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

                strumLine.strums.members[id].animation.play('pressed', true);
            }
		}
	}

    function releaseNote(id:Int)
    {
		for (strumLine in strumLines)
            if (strumLine.type == PLAYER)
                strumLine.strums.members[id].animation.play('idle', true);
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

            if (character.voicePrefix != null && character.voicePrefix.split(' ').join('') != '')
                character.voice = loadVoice(character.voicePrefix);

            var strumLine:StrumLine = new StrumLine(grid.sections, grid.type, character, function(_)
                {
                    if (grid.type == PLAYER)
                        health += 2;
                },
                function (_)
                {
                    if (grid.type == PLAYER)
                        health -= 2;
                }
            );

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

                    if (opponents.length == 0)
                    {
                        opponentIconName = character.icon;

                        opponentColor = character.barColor;
                    }

                    opponents.push(character);
                    
                    opponentStrums.push(strumLine);
                case PLAYER:
                    character.setPosition(STAGE.playersPosition[players.length][0], STAGE.playersPosition[players.length][1]);

                    if (players.length == 0)
                    {
                        playerIconName = character.icon;

                        playerColor = character.barColor;
                    }

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
	
	override function stepHit()
	{
		super.stepHit();

		if (SONG.needsVoices /* && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset*/)
			resyncVoices();

		callOnScripts('onStepHit');
		setOnScripts('curStep', curStep);
	}

	private function resyncVoices():Void
	{
		var timeSub:Float = Conductor.songPosition /*- Conductor.offset*/;
		var syncTime:Float = 10 /* * playbackRate*/;

        for (voice in voices)
        {
            if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime || (voice.length > 0 && Math.abs(voice.time - timeSub) > syncTime))
            {
                voice.pause();
        
                if (Conductor.songPosition <= voice.length)
                    voice.time = Conductor.songPosition;
        
                voice.play();
            }
        }
	}

    override function beatHit()
    {
        super.beatHit();

        setOnScripts('curBeat', curBeat);
        callOnScripts('onBeatHit');

        if (iconsZoomingFunction != null)
            iconsZoomingFunction();

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

        scoreTxt.text = 'FPS: ' + (1 / FlxG.elapsed);

        callOnScripts('onUpdate', [elapsed]);

        camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, cameraZoom, 0.1);
        camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.1);

        if (FlxG.keys.justPressed.R)
        {
            shouldClearMemory = false;

            FlxG.sound.music.pause();

            for (voice in voices)
                voice.pause();
            
            FlxG.resetState();
        }

        if (FlxG.keys.justPressed.B)
            botplay = !botplay;

        if (characters != null)
            for (character in characters)
                if (character.idleTimer < 60 / Conductor.bpm)
                    character.idleTimer += elapsed;

        if (iconsZoomLerpFunction != null)
            iconsZoomLerpFunction();

        if (iconsPositionFunction != null)
            iconsPositionFunction();
		
		healthBar.percent = CoolUtil.fpsLerp(healthBar.percent, 100 - health, 0.2);

        callOnScripts('onUpdatePost', [elapsed]);
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onFocus');

        FlxG.sound.music.play();

        for (voice in voices)
            voice.play();
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onFocusLost');

        FlxG.sound.music.pause();

        for (voice in voices)
            voice.pause();
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