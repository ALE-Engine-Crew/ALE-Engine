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

import utils.ALEParserHelper;

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
		
		healthBar.percent = health;

		return value;
	}

	public var iconsZoomingFunction:Int -> Void;
	public var iconsZoomLerpFunction:Void -> Void;
	public var iconsPositionFunction:Void -> Void;
	public var iconsAnimationFunction:Void -> Void;
    public var cameraZoomingFunction:Int -> Void;
    public var cameraZoomLerpFunction:Void -> Void;

    private var opponentIconName:String = '';
    private var playerIconName:String = '';

    private var opponentColor:FlxColor;
    private var playerColor:FlxColor;

	public var healthBar:Bar;

	public var scoreTxt:FlxText;

    public var paused:Bool = false;

    override function create()
    {
        super.create();

        instance = this;

        initScripts();

        setOnScripts('camGame', camGame);
        setOnScripts('camHUD', camHUD);
        
        callOnScripts('onCreate');

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);
		
		camGame.target = camPos;
		camGame.followLerp = 2.4 * STAGE.cameraSpeed;
        cameraZoom = STAGE.cameraZoom;

        spawnGrids();

        Conductor.bpm = SONG.bpm;

        scrollSpeed = SONG.speed;

        moveCamera();

        initAudios();

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

        initHUD();

        initCustomizableFunctions();

        callOnScripts('onCreatePost');
    }
	
	override function stepHit(curStep:Int)
	{
		super.stepHit(curStep);

        if (cameraZoomingFunction != null)
            cameraZoomingFunction(curStep);

        if (iconsZoomingFunction != null)
            iconsZoomingFunction(curStep);

		if (SONG.needsVoices /* && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset*/)
			resyncVoices();

		callOnScripts('onStepHit', [curStep]);
    }

    override function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

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

        callOnScripts('onBeatHit', [curBeat]);
    }

    override function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        moveCamera();

        callOnScripts('onSectionHit', [curSection]);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        callOnScripts('onUpdate', [elapsed]);

        if (cameraZoomLerpFunction != null)
            cameraZoomLerpFunction();

        if (FlxG.keys.justPressed.R)
            restartSong();

        if (FlxG.keys.justPressed.B)
            botplay = !botplay;

        if (FlxG.keys.justPressed.ENTER)
        {
            pauseSong();

            CoolUtil.openSubState(new CustomSubState(CoolVars.data.pauseSubState));
        }

        if (iconsZoomLerpFunction != null)
            iconsZoomLerpFunction();

        if (iconsPositionFunction != null)
            iconsPositionFunction();

        callOnScripts('onUpdatePost', [elapsed]);
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onFocus');

        if (!paused)
        {
            FlxG.sound.music.play();
    
            for (voice in voices)
                voice.play();
        }
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onFocusLost');

        if (!paused)
        {
            FlxG.sound.music.pause();
    
            for (voice in voices)
                voice.pause();
        }
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        super.openSubState(substate);

        callOnScripts('onOpenSubState', [substate]);
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        callOnScripts('onCloseSubState');
    }

    override public function destroy()
    {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

        callOnScripts('onDestroy');

        destroyScripts();

        super.destroy();
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

            var strumLine:StrumLine = new StrumLine(grid.sections, grid.type, character,
                function(_)
                {
                    if (grid.type == PLAYER)
                        health += 1.5;
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

    function moveCamera()
    {
        if (cameraSections[curSection] != null)
        {
            var curChar:Character = cameraSections[curSection];
    
            camPos.x = curChar.getMidpoint().x + curChar.cameraOffset[0];
            camPos.y = curChar.getMidpoint().y + curChar.cameraOffset[1];
        }
    }

    public function pauseSong()
    {
        paused = true;

        FlxG.sound.music.pause();

        for (voice in voices)
            voice.pause();
    }

    public function resumeSong()
    {
        paused = false;

        FlxG.sound.music.resume();

        for (voice in voices)
            voice.resume();
    }

    public function restartSong()
    {
        shouldClearMemory = false;

        pauseSong();
        
        CoolVars.skipTransOut = true;

        FlxG.resetState();
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

    private function initScripts()
    {
        if (Paths.fileExists(songRoute + '/scripts'))
            for (file in FileSystem.readDirectory(Paths.getPath(songRoute + '/scripts')))
                loadScript(songRoute + '/scripts/' + file);

        if (Paths.fileExists('scripts/songs'))
            for (file in FileSystem.readDirectory(Paths.getPath('scripts/songs')))
                loadScript('scripts/songs/' + file);

        STAGE = ALEParserHelper.getALEStage(SONG.stage);

        loadScript('stages/' + SONG.stage);
    }

    private function initAudios()
    {
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

        startPosition = 0;
    }

    private function initHUD()
    {
		healthBar = new Bar(null, ClientPrefs.data.downScroll ? 75 : FlxG.height - 70);
		add(healthBar);
		healthBar.cameras = [camHUD];
		healthBar.x = FlxG.width / 2 - healthBar.width / 2;
        healthBar.leftBar.color = opponentColor;
        healthBar.rightBar.color = playerColor;
        healthBar.orientation = RIGHT;

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
    }

    private function initCustomizableFunctions()
    {
        iconsZoomingFunction = (curStep) -> {
            if (curStep % 4 == 0)
            {
                playerIcon.scale.set(1.2, 1.2);
                playerIcon.updateHitbox();
        
                opponentIcon.scale.set(1.2, 1.2);
                opponentIcon.updateHitbox();
                
                if (iconsPositionFunction != null)
                    iconsPositionFunction();
            }
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
				}
	
				if (health >= 20 && playerIcon.animation.curAnim.curFrame != 0)
				{
					playerIcon.animation.curAnim.curFrame = 0;
				}
			}
	
			if (opponentIcon != null && opponentIcon.animation != null && opponentIcon.animation.curAnim != null)
			{
				if (health > 80 && opponentIcon.animation.curAnim.curFrame != 1)
				{
					opponentIcon.animation.curAnim.curFrame = 1;
				}
	
				if (health <= 80 && opponentIcon.animation.curAnim.curFrame != 0)
				{
					opponentIcon.animation.curAnim.curFrame = 0;
				}
			}
		};

        cameraZoomLerpFunction = () -> {
            camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, cameraZoom, 0.1);
            camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.1);
        };

        cameraZoomingFunction = (curStep) -> {
            if (curStep % 16 == 0)
            {
                camGame.zoom += 0.03;
                camHUD.zoom += 0.015;
            }
        };
    }
}