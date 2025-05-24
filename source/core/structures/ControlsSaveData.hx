package core.structures;

import flixel.input.keyboard.FlxKey;

import core.structures.NotesControls;
import core.structures.UIControls;
import core.structures.EngineControls;

@:structInit class ControlsSaveData
{
	public var notes:NotesControls = {
		left: [FlxKey.A, FlxKey.LEFT],
		down: [FlxKey.S, FlxKey.DOWN],
		up: [FlxKey.W, FlxKey.UP],
		right: [FlxKey.D, FlxKey.RIGHT]
	};

	public var ui:UIControls = {
		left: [FlxKey.A, FlxKey.LEFT],
		down: [FlxKey.S, FlxKey.DOWN],
		up: [FlxKey.W, FlxKey.UP],
		right: [FlxKey.D, FlxKey.RIGHT],
		accept: [FlxKey.ENTER, FlxKey.SPACE],
		back: [FlxKey.ESCAPE, null],
		reset: [FlxKey.R, FlxKey.F5],
		pause: [FlxKey.ENTER, FlxKey.ESCAPE]
	};

	public var engine:EngineControls = {
		switch_mod: [FlxKey.M, null],
		reset_game: [FlxKey.N, null],
		master_menu: [FlxKey.SEVEN, null],
		fps_counter: [FlxKey.F3, null],
		update_engine: [FlxKey.F4, null]
	};
}