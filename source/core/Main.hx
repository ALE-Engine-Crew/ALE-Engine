package core;

import flixel.FlxGame;
import openfl.display.Sprite;

import core.config.MainState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, MainState, true));
	}
}
