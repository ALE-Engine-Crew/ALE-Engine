package game.states;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.FlxObject;

import visuals.objects.Character;

import visuals.objects.HealthIcon;
import visuals.objects.Bar;

import visuals.objects.Note;
import visuals.objects.Splash;

import visuals.objects.StrumNote;
import visuals.objects.Note;

import openfl.events.KeyboardEvent;

import core.structures.*;
import core.enums.ALECharacterType;

class PlayState extends ScriptState
{
	public static var instance:PlayState;

	public static var startPosition:Float = 0;

	public static var SONG:ALESong = null;

	public var stage:ALEStage = null;

	public var voices:FlxSound;

	public var strumNotes:FlxGroup;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var splashes:FlxGroup;
	public var opponentSplashes:FlxTypedGroup<Splash>;
	public var playerSplashes:FlxTypedGroup<Splash>;

	public var notes:FlxGroup;
	public var opponentNotes:FlxTypedGroup<Note>;
	public var playerNotes:FlxTypedGroup<Note>;

	public var extraCharacters:FlxTypedGroup<Character>;
	public var opponentCharacters:FlxTypedGroup<Character>;
	public var playerCharacters:FlxTypedGroup<Character>;

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

	public var botplay(default, set):Bool;

	function set_botplay(value:Bool):Bool
	{
		botplay = value;

		if (botplay)
			scoreTxt.text = 'BOTPLAY';
		else
			scoreTxt.text = 'oso';

		return value;
	}

	var stageJson:ALEStage;

	var camPos:FlxObject;

	var opponentIcon:HealthIcon;
	var playerIcon:HealthIcon;

	public var healthBar:Bar;

	public var scoreTxt:FlxText;

	public var iconsZoomingFunction:Void -> Void;
	public var iconsZoomLerpFunction:Void -> Void;
	public var iconsPositionLerpFunction:Void -> Void;
	public var iconsAnimationFunction:Void -> Void;

	public var cameraZoomingFunction:Void -> Void;
	public var cameraLerpFunction:Void -> Void;

	public var defaultCamZoom:Float = 1;

	public var scrollSpeed(default, set):Float;

	function set_scrollSpeed(value:Float):Float
	{
		scrollSpeed = value;

		if (playerNotes.members.length > 0)
			for (note in playerNotes)
				note.scrollSpeed = value / 2;

		if (opponentNotes.members.length > 0)
			for (note in opponentNotes)
				note.scrollSpeed = value / 2;

		return value;
	}

	override function create()
	{
		super.create();
		
		instance = this;

		stage = loadStageJSON(SONG.stage);

		loadScripts();

		callOnScripts('onCreate');

		createCameras();

		createStrums();

		createCharacters();
		
		createUI();

		playSounds();

		setCustomizableFunctions();

		moveCamera();

		Conductor.bpm = SONG.bpm;

		scrollSpeed = SONG.speed;
		
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		callOnScripts('onCreatePost');
	}

	private function loadScripts()
	{
		for (script in FileSystem.readDirectory(Paths.getPath('data/' + CoolUtil.formatSongPath(SONG.song))))
		{
			if (script.endsWith('.hx'))
				loadHScript('data/' + CoolUtil.formatSongPath(SONG.song) + '/' + script.substr(0, script.length - 3));
			else if (script.endsWith('.lua'))
				loadLuaScript('data/' + CoolUtil.formatSongPath(SONG.song) + '/' + script.substr(0, script.length - 4));
		}
	}

	private function createCameras():Void
	{
		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);
		
		camGame.target = camPos;
		camGame.zoom = defaultCamZoom;
		camGame.followLerp = 2.4;
		camGame.followLerp = 2.4;

		defaultCamZoom = stage.cameraZoom;
	}

	private function moveCamera()
	{
		for (grid in SONG.grids)
		{
			if (grid.sections[curSection].cameraFocusThis)
			{
				switch (grid.type)
				{
					case OPPONENT:
						for (index => char in opponentCharacters)
						{
							if (char.name == grid.character)
							{
								camPos.x = char.getMidpoint().x + 150;
								camPos.x += char.cameraOffset[0] + stage.opponentsCamera[index][0];
								camPos.y = char.getMidpoint().y - 100;
								camPos.y += char.cameraOffset[1] + stage.opponentsCamera[index][1];
	
								break;
							}
						}
					case PLAYER:
						for (index => char in playerCharacters)
						{
							if (char.name == grid.character)
							{
								camPos.x = char.getMidpoint().x - 100;
								camPos.x -= char.cameraOffset[0] + stage.playersCamera[index][0];
								camPos.y = char.getMidpoint().y - 100;
								camPos.y += char.cameraOffset[1] + stage.playersCamera[index][1];
	
								break;
							}
						}
					case EXTRA:
						for (index => char in extraCharacters)
						{
							if (char.name == grid.character)
							{
								camPos.x = char.getMidpoint().x - 100;
								camPos.x += char.cameraOffset[0] + stage.extrasCamera[index][0];
								camPos.y = char.getMidpoint().y;
								camPos.y += char.cameraOffset[1] + stage.extrasCamera[index][1];
	
								break;
							}
						}
				}
			}
		}
	}

	private function createStrums():Void
	{
		strumNotes = new FlxGroup();
		add(strumNotes);
		strumNotes.cameras = [camHUD];
		
		notes = new FlxGroup();
		add(notes);
		notes.cameras = [camHUD];

		splashes = new FlxGroup();
		add(splashes);
		splashes.cameras = [camHUD];

		opponentStrums = new FlxTypedGroup<StrumNote>();
		strumNotes.add(opponentStrums);

		opponentNotes = new FlxTypedGroup<Note>();
		notes.add(opponentNotes);

		opponentSplashes = new FlxTypedGroup<Splash>();
		splashes.add(opponentSplashes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		strumNotes.add(playerStrums);

		playerNotes = new FlxTypedGroup<Note>();
		notes.add(playerNotes);

		playerSplashes = new FlxTypedGroup<Splash>();
		splashes.add(playerSplashes);
		
		for (gridIndex => grid in SONG.grids)
		{
			if (grid.type == EXTRA)
				continue;
				
			for (i in 0...4)
			{
				var splash:Splash = new Splash(i);

				var strumNote:StrumNote = new StrumNote(i + (grid.type == PLAYER ? 4 : 0), splash);

				splash.strum = strumNote;
				splash.texture = splash.texture;
				
				switch (grid.type)
				{
					case OPPONENT:
						opponentStrums.add(strumNote);
						opponentSplashes.add(splash);
					case PLAYER:
						playerStrums.add(strumNote);
						opponentSplashes.add(splash);
					case EXTRA:
				}
			}

			createNotes(grid.character, grid.sections, grid.type);
		}
	}

	private function createNotes(characterName:String, sections:Array<ALESection>, type:ALECharacterType):Void
	{
		for (section in sections)
		{
			for (noteArray in section.notes)
			{
				var theNote:Note = new Note(noteArray[1], noteArray[0], noteArray[2], type, 
					switch (type)
					{
						case OPPONENT:
							opponentStrums.members[noteArray[1] + Math.floor((opponentStrums.members.length - 1) / 4) * 4];
						case PLAYER:
							playerStrums.members[noteArray[1] + Math.floor((playerStrums.members.length - 1) / 4) * 4];
						case EXTRA:
							trace('Extra Type Note Shouldn\'t be Here!');

							null;
					}
				);

				switch (type)
				{
					case OPPONENT:
						opponentNotes.add(theNote);
					case PLAYER:
						playerNotes.add(theNote);
					case EXTRA:
				}

				theNote.hitCallback = (note:Note) -> {
					note.strum.animation.play('hit');

					if (note.type == PLAYER)
						note.strum.splash.animation.play('splash');

					if (note.type == PLAYER)
						health += 2;

					var character:Null<Character> = null;

					for (char in switch (type)
							{
								case OPPONENT:
									opponentCharacters;
								case PLAYER:
									playerCharacters;
								case EXTRA:
									extraCharacters;
							}
						)
					{
						if (char.name == characterName)
						{
							character = char;

							break;
						}
					}

					if (character != null)
					{
						character.idleTimer = 0;

						if (character.animation.curAnim != null)
							character.animation.curAnim.finish();

						character.animation.play(
							switch (note.noteData)
							{
								case 0:
									'singLEFT';
								case 1:
									'singDOWN';
								case 2:
									'singUP';
								case 3:
									'singRIGHT';
								default:
									'';
							}
						);
					}
				}
				
				theNote.loseCallback = (note:Note) -> {
					health -= 2;
				}
			}
		}
	}

	private function createCharacters()
	{
		extraCharacters = new FlxTypedGroup<Character>();
		add(extraCharacters);

		opponentCharacters = new FlxTypedGroup<Character>();
		add(opponentCharacters);
		
		playerCharacters = new FlxTypedGroup<Character>();
		add(playerCharacters);

		for (grid in SONG.grids)
		{
			var character:Character = new Character(grid.character, grid.type == PLAYER);
			
			switch (grid.type)
			{
				case OPPONENT:
					opponentCharacters.add(character);
					character.x = stage.opponentsPosition[opponentCharacters.members.length - 1][0];
					character.y = stage.opponentsPosition[opponentCharacters.members.length - 1][1];
				case PLAYER:
					playerCharacters.add(character);
					character.x = stage.playersPosition[playerCharacters.members.length - 1][0];
					character.y = stage.playersPosition[playerCharacters.members.length - 1][1];
				case EXTRA:
					extraCharacters.add(character);
					character.x = stage.extrasPosition[extraCharacters.members.length - 1][0];
					character.y = stage.extrasPosition[extraCharacters.members.length - 1][1];
			}
		}
	}

	function createUI()
	{
		healthBar = new Bar(null, 640);
		add(healthBar);
		healthBar.cameras = [camHUD];
		healthBar.x = FlxG.width / 2 - healthBar.width / 2;
		healthBar.leftColor = FlxColor.fromRGB(opponentCharacters.members[0].barColors[0], opponentCharacters.members[0].barColors[1], opponentCharacters.members[0].barColors[2]);
		healthBar.rightColor = FlxColor.fromRGB(playerCharacters.members[0].barColors[0], playerCharacters.members[0].barColors[1], playerCharacters.members[0].barColors[2]);

		playerIcon = new HealthIcon(playerCharacters.members[0].icon);
		add(playerIcon);
		playerIcon.flipX = true;
		playerIcon.cameras = [camHUD];
		playerIcon.y = healthBar.y + healthBar.height / 2 - playerIcon.height / 2;

		opponentIcon = new HealthIcon(opponentCharacters.members[0].icon);
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

	private function setCustomizableFunctions()
	{
		iconsZoomLerpFunction = () -> {
			playerIcon.scale.x = CoolUtil.fpsLerp(playerIcon.scale.x, 1, 0.33);
			playerIcon.scale.y = CoolUtil.fpsLerp(playerIcon.scale.y, 1, 0.33);
			playerIcon.updateHitbox();
	
			opponentIcon.scale.x = CoolUtil.fpsLerp(opponentIcon.scale.x, 1, 0.33);
			opponentIcon.scale.y = CoolUtil.fpsLerp(opponentIcon.scale.y, 1, 0.33);
			opponentIcon.updateHitbox();
		}

		iconsZoomingFunction = () -> {
			playerIcon.scale.set(1.2, 1.2);
			playerIcon.updateHitbox();
	
			opponentIcon.scale.set(1.2, 1.2);
			opponentIcon.updateHitbox();
	
			iconsPositionLerpFunction();
		}

		iconsPositionLerpFunction = () -> {
			playerIcon.x = healthBar.x + healthBar.middlePoint;
	
			opponentIcon.x = healthBar.x + healthBar.middlePoint - opponentIcon.width;
		}

		iconsAnimationFunction = () -> {
			if (playerIcon != null && playerIcon.animation != null && playerIcon.animation.curAnim != null)
			{
				if (healthBar.percent < 20 && playerIcon.animation.curAnim.curFrame != 1)
				{
					playerIcon.animation.curAnim.curFrame = 1;

					playerIcon.updateHitbox();
				
					playerIcon.y = healthBar.y + healthBar.height / 2 - playerIcon.height / 2;
				}
	
				if (healthBar.percent >= 20 && playerIcon.animation.curAnim.curFrame != 0)
				{
					playerIcon.animation.curAnim.curFrame = 0;

					playerIcon.updateHitbox();
				
					playerIcon.y = healthBar.y + healthBar.height / 2 - playerIcon.height / 2;
				}
			}
	
			if (opponentIcon != null && opponentIcon.animation != null && opponentIcon.animation.curAnim != null)
			{
				if (healthBar.percent > 80 && opponentIcon.animation.curAnim.curFrame != 1)
				{
					opponentIcon.animation.curAnim.curFrame = 1;

					opponentIcon.y = healthBar.y + healthBar.height / 2 - opponentIcon.height / 2;
				}
	
				if (healthBar.percent <= 80 && opponentIcon.animation.curAnim.curFrame != 0)
				{
					opponentIcon.animation.curAnim.curFrame = 0;
					
					opponentIcon.y = healthBar.y + healthBar.height / 2 - opponentIcon.height / 2;
				}
			}
		};

		cameraZoomingFunction = () -> {
			camGame.zoom += 0.03;
			camHUD.zoom += 0.015;
		}

		cameraLerpFunction = () -> {
			camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, defaultCamZoom, 0.1);
			camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.1);
		}
	}

	function playSounds()
	{
		FlxG.sound.music = Paths.inst(SONG.song);
		FlxG.sound.music.play();

		FlxG.sound.music.volume = 0.6;

		voices = Paths.voices(SONG.song);
		voices.play();

		FlxG.sound.list.add(voices);

		FlxG.sound.music.time = voices.time = startPosition;
	}

	function onKeyPress(event:KeyboardEvent)
	{
		if (botplay)
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
	}

	function onKeyRelease(event:KeyboardEvent)
	{
		if (botplay)
			return;

		var allowedKeys:Array<Int> = [68, 70, 74, 75];

		if (!allowedKeys.contains(event.keyCode))
			return;

		for (strumIndex => strum in playerStrums)
			if (strumIndex % 4 == 
				switch(event.keyCode)
				{
					case 68:
						0;
					case 70:
						1;
					case 74:
						2;
					case 75:
						3;
					default:
						-1;
				}
			)
				strum.animation.play('released');
	}

	function hitNote(id:Int)
	{
		var anim:String = 'pressed';

		for (note in playerNotes)
		{
			if (id % 4 == note.noteData && note.type == ALECharacterType.PLAYER && note.alive && note.y >= note.strum.y - 100 * scrollSpeed && note.y <= note.strum.y + 100 * scrollSpeed)
			{
				note.hitFunction();

				anim = 'hit';

				return;
			}
		}
	}

	override function update(elapsed:Float)
	{
		callOnScripts('onUpdate', [elapsed]);

		if (FlxG.keys.justPressed.B)
			botplay = !botplay;

		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState();

			PlayState.startPosition = FlxMath.bound(FlxG.sound.music.time - 5000, 0, FlxG.sound.music.length);
		}

		updateCameras();

		updateCharacters(elapsed);

		updateIcons();
		
		healthBar.percent = CoolUtil.fpsLerp(healthBar.percent, 100 - health, 0.2);

		super.update(elapsed);

		callOnScripts('onUpdatePost', [elapsed]);
	}

	private function updateCameras():Void
	{
		cameraLerpFunction();
	}

	private function updateCharacters(elapsed:Float):Void
	{
		for (character in opponentCharacters)
			if (character.idleTimer < 60 / Conductor.bpm)
				character.idleTimer += elapsed;

		for (character in playerCharacters)
			if (character.idleTimer < 60 / Conductor.bpm)
				character.idleTimer += elapsed;

		for (character in extraCharacters)
			if (character.idleTimer < 60 / Conductor.bpm)
				character.idleTimer += elapsed;
	}

	function updateIcons()
	{
		iconsZoomLerpFunction();
		iconsPositionLerpFunction();
	}

	override function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		
		callOnScripts('onDestroy');

		destroyScripts();

		instance = null;

		super.destroy();
	}
	
	override function stepHit()
	{
		if (SONG.needsVoices /* && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset*/)
			resyncVoices();

		callOnScripts('onStepHit');
		setOnScripts('curStep', curStep);

		super.stepHit();
	}

	private function resyncVoices():Void
	{
		var timeSub:Float = Conductor.songPosition /*- Conductor.offset*/;
		var syncTime:Float = 20 /* * playbackRate*/;

		if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime || (voices.length > 0 && Math.abs(voices.time - timeSub) > syncTime))
		{
			voices.pause();
	
			FlxG.sound.music.play();
	
			if (Conductor.songPosition <= voices.length)
				voices.time = Conductor.songPosition;
	
			voices.play();
		}
	}

	override function beatHit()
	{
		iconsZoomingFunction();

		if (curBeat % 4 == 0)
		{
			cameraZoomingFunction();
		}

		if (curBeat % 2 == 0)
		{
			for (character in opponentCharacters)
				if (character.idleTimer >= 60 / Conductor.bpm)
					character.animation.play('idle');
	
			for (character in playerCharacters)
				if (character.idleTimer >= 60 / Conductor.bpm)
					character.animation.play('idle');
			
			for (character in extraCharacters)
				if (character.idleTimer >= 60 / Conductor.bpm)
					character.animation.play('danceLeft');
		} else if (curBeat % 2 == 1) {
			for (character in extraCharacters)
				if (character.idleTimer >= 60 / Conductor.bpm)
					character.animation.play('danceRight');
		}

		callOnScripts('onBeatHit');
		setOnScripts('curBeat', curBeat);

		super.beatHit();
	}

	override function sectionHit()
	{
		moveCamera();

		callOnScripts('onSectionHit');
		setOnScripts('curSection', curSection);
		
		super.sectionHit();
	}

	override function onFocus()
	{
		FlxG.sound.music.resume();
		voices.resume();

		callOnScripts('onFocus');

		super.onFocus();
	}

	override function onFocusLost()
	{
		FlxG.sound.music.pause();
		voices.pause();

		callOnScripts('onFocusLost');

		super.onFocusLost();
	}

	public function loadStageJSON(name:String):ALEStage
	{
		if (Paths.fileExists('stages/' + name + '.json'))
		{
			return returnALEStage(tjson.TJSON.parse(File.getContent(Paths.getPath('stages/' + name + '.json'))));
		} else {
			trace('Missing File: stages/' + name + '.json');
			
			return null;
		}
	}

	function returnALEStage(data:Dynamic):ALEStage
	{
		if (data.format == 'ale-format-v0.1')
		{
			return cast data;
		} else {
			var formattedStage:Dynamic = {
				opponentsPosition: data.opponent == null ? [[0, 0]] : [data.opponent],
				playersPosition: data.boyfriend == null ? [[0, 0]] : [data.boyfriend],
				extrasPosition: data.girlfriend == null ? [[0, 0]] : [data.girlfriend],

				opponentsCamera: data.camera_opponent == null ? [[0, 0]] : [data.camera_opponent],
				playersCamera: data.camera_boyfriend == null ? [[0, 0]] : [data.camera_boyfriend],
				extrasCamera: data.camera_girlfriend == null ? [[0, 0]] : [data.camera_girlfriend],

				format: 'ale-format-v0.1',

				cameraZoom: data.defaultCamZoom == null ? 1 : data.defaultZoom,
				cameraSpeed: data.camera_speed == null ? 1 : data.camera_speed
			};

			return cast formattedStage;
		}
	}
}