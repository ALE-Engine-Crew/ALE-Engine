package funkin.states;

import utils.ALEParserHelper;

import core.enums.ALECharacterType;
import core.enums.Rating;
import core.enums.Rank;

import core.structures.ALESong;
import core.structures.ALEStage;

import scripting.haxe.HScript;
import scripting.lua.LuaScript;

import funkin.visuals.game.*;

import funkin.visuals.objects.Bar;
import funkin.visuals.objects.HealthIcon;

import flixel.sound.FlxSound;
import flixel.FlxObject;

class PlayState extends ScriptState
{
    public static var instance:PlayState;

    public static var startPosition:Float = 0;

    public var strumLines:StrumLinesGroup = new StrumLinesGroup();

    public var characters:CharactersGroup = new CharactersGroup();

    public var scrollSpeed(default, set):Float = 1;
    public function set_scrollSpeed(value:Float):Float
    {
        scrollSpeed = value;

        if (strumLines != null)
            for (grp in strumLines.getGroups())
                for (strl in grp)
                    strl.scrollSpeed = scrollSpeed;

        return scrollSpeed;
    }

    public static var SONG:ALESong = null;
    public static var STAGE:ALEStage = null;

    public static var difficulty:String = null;

    public static var songRoute:String = null;

    public var instrumental:FlxSound;
    public var voices:FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();

	public var camPosition:FlxObject;

    public var cameraZoom:Float = 1;
    public var hudZoom:Float = 1;

    public var health(default, set):Float = 50;
    public function set_health(value:Float):Float
    {
        if (value < 0)
            value = 0;

        if (value > 100)
            value = 100;

        health = value;

        iconsAnimationFunction();
		
		healthBar.percent = health;

		scoreTxt.applyMarkup('Score: ' + score + '    Misses: ' + misses + '    Rating: *' + rankToString(rank) + '*' + (rank == null ? '' : ' - ' + CoolUtil.floorDecimal(accuracy, 2) + '%'), [new FlxTextFormatMarkerPair(new FlxTextFormat(rankToColor(rank)), '*')]);

        return health;
    }

    public var noteCombo:Int = 0;
    public var misses:Int = 0;
    public var sicks:Int = 0;
    public var goods:Int = 0;
    public var bads:Int = 0;
    public var shits:Int = 0;

    public var score(get, never):Int;
    public function get_score():Int
        return sicks * 350 + goods * 200 + bads * 100 + misses * -100;

    public var accuracy(get, never):Float;
    public function get_accuracy():Float
    {
        var total:Int = sicks + goods + bads + shits + misses;
        var maxScore:Int = total * 100;
        var score:Int = sicks * 100 + goods * 75 + bads * 40 + shits * 20;
        
        return total == 0 ? 0 : score / total;
    }

    public var rank(get, never):Null<Rank>;
    public function get_rank():Null<Rank>
    {
        if (accuracy <= 0)
            return null;

        if (accuracy < 40)
            return LOSS;
        else if (accuracy < 55)
            return GOOD;
        else if (accuracy < 70)
            return GREAT;
        else if (accuracy < 85)
            return EXCELLENT;
        else if (accuracy < 100)
            return SICK;
        else
            return PERFECT;
    }

    public function rankToString(rank:Null<Rank>):String
    {
        return switch(rank)
        {
            case null:
                '[N/A]';
            case LOSS:
                'L';
            case GOOD:
                'G';
            case GREAT:
                'G+';
            case EXCELLENT:
                'E';
            case SICK:
                'S';
            case PERFECT:
                'S++';
        }
    }

    public function rankToColor(rank:Null<Rank>):FlxColor
    {
        return switch(rank)
        {
            case null:
                0xFF909090;
            case LOSS:
                0xFFFF0000;
            case GOOD:
                0xFFFFAE00;
            case GREAT:
                0xFFFFFF00;
            case EXCELLENT:
                0xFF66FF66;
            case SICK:
                0xFF00FFFF;
            case PERFECT:
                0xFFFF00FF;
        }
    }

    public var comboGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

    public var opponentIcon:HealthIcon;
    public var playerIcon:HealthIcon;

    private var opponentIconName:String = '';
    private var playerIconName:String = '';

    private var opponentColor:FlxColor;
    private var playerColor:FlxColor;

	public var healthBar:Bar;

	public var scoreTxt:FlxText;

    public static var deathCounter:Int = 0;

    public var dead:Bool = false;

    public var paused:Bool = false;

    override function create()
    {
        super.create();

        instance = this;

        initScripts();
        
        callOnScripts('onCreate');

		camPosition = new FlxObject(0, 0, 1, 1);
		add(camPosition);
		
		camGame.target = camPosition;
		camGame.followLerp = 2.4 * STAGE.cameraSpeed;
        cameraZoom = STAGE.cameraZoom;
        
        cacheAssets();

        initAudios();

        initCharacters();
        
        initStrums();

        initHUD();

        moveCamera(0);
        
        Conductor.bpm = SONG.bpm;

        scrollSpeed = SONG.speed;

        callOnScripts('postCreate');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, cameraZoom, 0.05);
        camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, hudZoom, 0.05);

        iconsZoomLerpFunction();
        iconsPositionFunction();

        if (FlxG.keys.justPressed.ENTER && !dead)
        {
            pauseSong();

            CoolUtil.openSubState(new CustomSubState(CoolVars.data.pauseSubState));
        }

        callOnScripts('postUpdate', [elapsed]);
    }

    override public function destroy()
    {
        super.destroy();

        callOnScripts('onDestroy');
        
        instance = null;

        callOnScripts('postDestroy');

        destroyScripts();
    }
	
	override function stepHit(curStep:Int)
	{
		super.stepHit(curStep);

		callOnScripts('onStepHit', [curStep]);
        
		if (SONG.needsVoices /* && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset*/)
			resyncVoices();

        callOnScripts('postStepHit', [curStep]);
    }

    override function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        callOnScripts('onBeatHit', [curBeat]);

        if (curBeat % 2 == 0)
        {
            for (charGroup in characters.getGroups())
                for (character in charGroup)
                    if (character.finishedIdleTimer && character.allowIdle)
                        if (character.animation.exists('idle'))
                            character.animation.play('idle', true);
                        else if (character.animation.exists('danceLeft'))
                            character.animation.play('danceLeft', true);
        } else if (curBeat % 2 == 1) {
            for (charGroup in characters.getGroups())
                for (character in charGroup)
                    if (character.animation.exists('danceRight') && character.finishedIdleTimer && character.allowIdle)
                        character.animation.play('danceRight', true);
        }

        if (curBeat % 4 == 0)
        {
            camGame.zoom += 0.015;
            camHUD.zoom += 0.03;
        }

        iconsZoomingFunction();

        callOnScripts('postBeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        callOnScripts('onSectionHit', [curSection]);

        moveCamera(curSection);

        callOnScripts('postSectionHit', [curSection]);
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onOnFocus');

        callOnScripts('postOnFocus');
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onOnFocusLost');

        callOnScripts('postOnFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        super.openSubState(substate);

        callOnScripts('onOpenSubState', [substate]);

        callOnScripts('postOpenSubState', [substate]);
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        callOnScripts('onCloseSubState');

        callOnScripts('postCloseSubState');
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

    public function restartSong(skipIn:Bool = true, skipOut:Bool = true)
    {
        shouldClearMemory = false;

        pauseSong();
        
        CoolVars.skipTransIn = skipIn;
        CoolVars.skipTransOut = skipOut;

        FlxG.resetState();
    }
    
    private function initScripts()
    {
        STAGE = ALEParserHelper.getALEStage(SONG.stage);

        cameraZoom = STAGE.cameraZoom;

        loadScript('stages/' + SONG.stage);

        for (folder in ['scripts/songs', songRoute + '/scripts'])
            if (Paths.fileExists(folder))
                for (file in FileSystem.readDirectory(Paths.getPath(folder)))
                    if (file.endsWith('.hx') || file.endsWith('.lua'))
                        loadScript(folder + '/' + file);
    }

    private function cacheAssets()
    {
        callOnScripts('onCacheAssets');

        var images:Array<String> = [
            'ui/alphabet'
        ];

        for (image in images)
            Paths.image(image);
        
        callOnScripts('postCacheAssets');
    }

    private function initAudios()
    {
        callOnScripts('onInitAudios');
        
		instrumental = new FlxSound().loadEmbedded(Paths.inst(songRoute));
        instrumental.volume = 0.6;

		FlxG.sound.list.add(instrumental);

        loadVoice();
        
        loadVoice('Player');
        
        loadVoice('Extra');
        
        loadVoice('Opponent');
        
		@:privateAccess FlxG.sound.playMusic(instrumental._sound, 1, false);
        FlxG.sound.music.volume = 0.6;
        FlxG.sound.pause();

		FlxG.sound.music.time = startPosition;

        for (voice in voices)
            voice.time = startPosition;

        FlxG.sound.music.play();
        
        for (voice in voices)
            voice.play();

        startPosition = 0;
        
        callOnScripts('postInitAudios');
    }

    private var charactersArray:Array<Character> = [];

    private function initCharacters()
    {
        callOnScripts('onInitCharacters');

        add(characters);

        for (character in SONG.characters)
        {
            var type:ALECharacterType = cast character[1];

            var object = new Character(
                switch (type)
                {
                    case OPPONENT:
                        STAGE.opponentsPosition[characters.opponents.members.length][0];
                    case PLAYER:
                        STAGE.playersPosition[characters.players.members.length][0];
                    case EXTRA:
                        STAGE.extrasPosition[characters.extras.members.length][0];
                },
                switch (type)
                {
                    case OPPONENT:
                        STAGE.opponentsPosition[characters.opponents.members.length][1];
                    case PLAYER:
                        STAGE.playersPosition[characters.players.members.length][1];
                    case EXTRA:
                        STAGE.extrasPosition[characters.extras.members.length][1];
                },
                character[0], cast character[1]
            );

            charactersArray.push(object);

            var objectColor:Array<Int> = object.data.barColor;
                
            switch (type)
            {
                case PLAYER:
                    if (characters.players.members.length <= 0)
                    {
                        playerIconName = object.data.icon;
                        playerColor = FlxColor.fromRGB(objectColor[0], objectColor[1], objectColor[2]);
                    }

                    characters.players.add(object);
                case OPPONENT:
                    if (characters.opponents.members.length <= 0)
                    {
                        opponentIconName = object.data.icon;
                        opponentColor = FlxColor.fromRGB(objectColor[0], objectColor[1], objectColor[2]);
                    }

                    characters.opponents.add(object);
                case EXTRA:
                    characters.extras.add(object);
            }
        }

        callOnScripts('postInitCharacters');
    }

    private function initStrums()
    {
        callOnScripts('onInitStrums');
        
        add(strumLines);
        strumLines.cameras = [camHUD];
        
        for (index => character in charactersArray)
        {
            var notes:Array<Array<Dynamic>> = [];

            for (section in SONG.sections)
                for (note in section.notes)
                    if (note[4] == index)
                        notes.push(note);

            var strl:StrumLine = new StrumLine(character, notes);
            strl.noteHitCallback = function(note:Note, rating:Rating)
            {
                showRatings(rating);
                
                if (strl.character.type == PLAYER)
                {
                    if (rating != null)
                    {
                        if (rating == SICK)
                            sicks++;
                        else if (rating == GOOD)
                            goods++;
                        else if (rating == BAD)
                            bads++;
                        else if (rating == SHIT)
                            shits++;
                    }

                    health += 1.5;
                }
                
                callOnScripts('onNoteHit', [note, rating]);
            }
            strl.noteMissCallback = function(note:Note)
            {
                noteCombo = 0;

                if (strl.character.type == PLAYER)
                {
                    misses++;

                    health -= 2.5;
                }

                if (health <= 0)
                {
                    pauseSong();

                    dead = true;

                    deathCounter++;

                    CoolUtil.openSubState(new CustomSubState(CoolVars.data.gameOverScreen));
                }
                
                callOnScripts('onNoteMiss', [note]);
            }

            switch (character.type)
            {
                case PLAYER:
                    strumLines.players.add(strl);
                case OPPONENT:
                    strumLines.opponents.add(strl);
                case EXTRA:
                    strumLines.extras.add(strl);
            }
        }
        
        callOnScripts('postInitStrums');
    }

    private function initHUD()
    {
        callOnScripts('onInitHUD');

        comboGroup.cameras = [this.camHUD];
        add(comboGroup);
        
        var popup:FlxSprite = new FlxSprite();
        popup.frames = Paths.getSparrowAtlas('ratings/default/ratings');
        for (anim in ['sick', 'good', 'bad', 'shit'])
            popup.animation.addByPrefix(anim, anim, 1, false);
        popup.alpha = 0;
        popup.scale.set(0.75, 0.75);
        popup.updateHitbox();
        popup.animation.onFrameChange.add(
            function(name:String, frameNumber:Int, frameIndex:Int)
            {
                popup.centerOffsets();
                popup.centerOrigin();
            }
        );
        popup.antialiasing = ClientPrefs.data.antialiasing;
        comboGroup.add(popup);

        for (i in 0...3)
        {
            var number:FlxSprite = new FlxSprite();
            number.frames = Paths.getSparrowAtlas('ratings/default/numbers');
            for (i in 0...10)
                number.animation.addByPrefix(Std.string(i), Std.string(i), 1, false);
            number.alpha = 0;
            number.scale.set(0.45, 0.45);
            number.updateHitbox();
            number.animation.onFrameChange.add(
                function(name:String, frameNumber:Int, frameIndex:Int)
                {
                    number.centerOffsets();
                    number.centerOrigin();
                }
            );
            number.antialiasing = ClientPrefs.data.antialiasing;

            comboGroup.add(number);
        }
        
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
		scoreTxt.applyMarkup('Score: ' + score + '    Misses: ' + misses + '    Rating: *' + rankToString(rank) + '*', [new FlxTextFormatMarkerPair(new FlxTextFormat(rankToColor(rank)), '*')]);

        callOnScripts('postInitHUD');
    }

    public dynamic function showRatings(rating:Rating)
    {
        if (rating != null)
        {
            if (noteCombo >= 999)
                noteCombo = 0;

            noteCombo++;

            var popup:FlxSprite = comboGroup.members[0];
            popup.animation.play(
                switch(rating)
                {
                    case SICK:
                        'sick';
                    case GOOD:
                        'good';
                    case BAD:
                        'bad';
                    case SHIT:
                        'shit';
                }
            );
            popup.updateHitbox();

            FlxTween.cancelTweensOf(popup);

            popup.x = 425;
            popup.y = 250;
            popup.alpha = 1;

            FlxTween.tween(popup, {y: popup.y - 20}, 0.3, {
                ease: FlxEase.cubeOut,
                onComplete: (_) -> {
                    FlxTween.tween(popup, {y: popup.y + 40}, 0.3, {ease: FlxEase.cubeIn});
                    FlxTween.tween(popup, {alpha: 0}, 0.3);
                }
            });

            for (i in 0...3)
            {
                var number:FlxSprite = comboGroup.members[i + 1];

                FlxTween.cancelTweensOf(number);

                number.alpha = 1;
                number.x = popup.x + 42.5 * i - number.width / 2;
                number.y = popup.y + 100;
                number.animation.play(Std.string(noteCombo).lpad('0', 3).split('')[i]);

                FlxTween.tween(number, {y: number.y - 20}, 0.3 + FlxG.random.float(0, 0.3), {
                    ease: FlxEase.cubeOut,
                    onComplete: (_) -> {
                        FlxTween.tween(number, {y: number.y + 40}, 0.3 + FlxG.random.float(0, 0.1), {ease: FlxEase.cubeIn});
                        FlxTween.tween(number, {alpha: 0}, 0.3);
                    }
                });
            }
        }
    }
    
    private function iconsZoomingFunction()
    {
        playerIcon.scale.set(1.2, 1.2);
        playerIcon.updateHitbox();

        opponentIcon.scale.set(1.2, 1.2);
        opponentIcon.updateHitbox();
        
        iconsPositionFunction();
    }

    private function iconsZoomLerpFunction()
    {
        playerIcon.scale.x = CoolUtil.fpsLerp(playerIcon.scale.x, 1, 0.33);
        playerIcon.scale.y = CoolUtil.fpsLerp(playerIcon.scale.y, 1, 0.33);
        playerIcon.updateHitbox();

        opponentIcon.scale.x = CoolUtil.fpsLerp(opponentIcon.scale.x, 1, 0.33);
        opponentIcon.scale.y = CoolUtil.fpsLerp(opponentIcon.scale.y, 1, 0.33);
        opponentIcon.updateHitbox();
    }

    private function iconsPositionFunction()
    {
        playerIcon.x = healthBar.x + healthBar.middlePoint - playerIcon.width / 10;

        opponentIcon.x = healthBar.x + healthBar.middlePoint - opponentIcon.width + opponentIcon.width / 10;
    }

    private function iconsAnimationFunction()
    {
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
    }

	private function resyncVoices():Void
	{
        callOnScripts('onResyncVoices');

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

        callOnScripts('postResyncVoices');
	}

    private function loadVoice(?prefix:String = ''):FlxSound
    {
        if (Paths.voices(songRoute, prefix) == null || !SONG.needsVoices)
            return null;
        
        var sound:FlxSound = new FlxSound();
        sound.loadEmbedded(Paths.voices(songRoute, prefix));
        sound.looped = false;

        voices.add(sound);

		FlxG.sound.list.add(sound);

        return sound;
    }

    private function moveCamera(section:Int)
    {
        if (SONG.sections[section] != null)
        {
            var char:Character = charactersArray[SONG.sections[section].focus];
    
            switch (char.type)
            {
                case OPPONENT:
                    camPosition.x = char.getMidpoint().x + 150;
                    camPosition.x += char.cameraPosition[0] + STAGE.opponentsCamera[characters.opponents.members.indexOf(char)][0];
                    camPosition.y = char.getMidpoint().y - 100;
                    camPosition.y += char.cameraPosition[1] + STAGE.opponentsCamera[characters.opponents.members.indexOf(char)][1];
                case PLAYER:
                    camPosition.x = char.getMidpoint().x - 100;
                    camPosition.x -= char.cameraPosition[0] + STAGE.playersCamera[characters.players.members.indexOf(char)][0];
                    camPosition.y = char.getMidpoint().y - 100;
                    camPosition.y += char.cameraPosition[1] + STAGE.playersCamera[characters.players.members.indexOf(char)][1];
                case EXTRA:
                    camPosition.x = char.getMidpoint().x - 100;
                    camPosition.x += char.cameraPosition[0] + STAGE.extrasCamera[characters.extras.members.indexOf(char)][0];
                    camPosition.y = char.getMidpoint().y;
                    camPosition.y += char.cameraPosition[1] + STAGE.extrasCamera[characters.extras.members.indexOf(char)][1];
            }
        }
    }
    
    override public function loadHScript(path:String)
    {
        #if HSCRIPT_ALLOWED
        if (Paths.fileExists(path + '.hx'))
        {
            try
            {
                var script:HScript = new HScript(Paths.getPath(path + '.hx'), STATE);
    
                if (script.parsingException != null)
                {
                    debugPrint('Error on Loading: ' + script.parsingException.message, ERROR);

                    script.destroy();
                } else {
                    hScripts.push(script);

                    new scripting.haxe.HaxePlayState(script);

                    debugTrace('"' + path + '.hx" has been Successfully Loaded', HSCRIPT);
                }
            } catch (error) {
                debugPrint('Error: ' + error.message, ERROR);
            }
        }
        #end
    }

    override public function loadLuaScript(path:String)
    {
        #if LUA_ALLOWED
        if (Paths.fileExists(path + '.lua'))
        {
            var script:LuaScript = new LuaScript(Paths.getPath(path + '.lua'), STATE);

            try
            {
                luaScripts.push(script);

                new scripting.lua.LuaPlayState(script);

                debugTrace('"' + path + '.lua" has been Successfully Loaded', LUA);
            } catch(error) {
                debugPrint('Error: ' + error, ERROR);
            }
        }
        #end
    }
}