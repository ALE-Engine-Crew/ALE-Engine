package funkin.states;

import utils.ALEParserHelper;

import core.enums.ALECharacterType;

import core.structures.ALESong;
import core.structures.ALEStage;

import scripting.haxe.HScript;
import scripting.lua.LuaScript;

import funkin.visuals.game.*;

import flixel.sound.FlxSound;
import flixel.FlxObject;

class PlayState extends ScriptState
{
    public static var instance:PlayState;

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

        Paths.image('ui/alphabet');

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

        for (voice in voices)
            voice.play();
        
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
                
            switch (type)
            {
                case PLAYER:
                    characters.players.add(object);
                case OPPONENT:
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