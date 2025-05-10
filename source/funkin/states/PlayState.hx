package funkin.states;

import utils.ALEParserHelper;

import core.enums.ALECharacterType;

import core.structures.ALESong;
import core.structures.ALEStage;

import scripting.haxe.HScript;
import scripting.lua.LuaScript;

import funkin.visuals.game.*;

import flixel.sound.FlxSound;

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

    override function create()
    {
        super.create();

        instance = this;

        initScripts();
        
        callOnScripts('onCreate');
        
        cacheAssets();

        initAudios();
        
        initStrums();
        
        Conductor.bpm = SONG.bpm;

        scrollSpeed = SONG.speed;

        callOnScripts('postCreate');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

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

        callOnScripts('postBeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        callOnScripts('onSectionHit', [curSection]);

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

    private function initStrums()
    {
        callOnScripts('onInitStrums');

        add(characters);
        
        add(strumLines);
        strumLines.cameras = [camHUD];
        
        for (grid in SONG.grids)
        {
            var character = new Character(
                switch (grid.type)
                {
                    case OPPONENT:
                        STAGE.opponentsPosition[characters.opponents.members.length][0];
                    case PLAYER:
                        STAGE.playersPosition[characters.players.members.length][0];
                    case EXTRA:
                        STAGE.extrasPosition[characters.extras.members.length][0];
                },
                switch (grid.type)
                {
                    case OPPONENT:
                        STAGE.opponentsPosition[characters.opponents.members.length][1];
                    case PLAYER:
                        STAGE.playersPosition[characters.players.members.length][1];
                    case EXTRA:
                        STAGE.extrasPosition[characters.extras.members.length][1];
                },
                grid.character, grid.type
            );

            var strl:StrumLine = new StrumLine(character, grid.sections);

            switch (grid.type)
            {
                case PLAYER:
                    characters.players.add(character);

                    strumLines.players.add(strl);
                case OPPONENT:
                    characters.opponents.add(character);

                    strumLines.opponents.add(strl);
                case EXTRA:
                    characters.extras.add(character);

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