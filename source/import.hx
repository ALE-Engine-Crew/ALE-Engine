import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import game.states.PlayState;
import game.states.CustomState;

import core.backend.MusicBeatState;
import core.backend.MusicBeatSubState;
import core.backend.ScriptState;
import core.backend.Conductor;

import core.config.ClientPrefs;

import utils.helpers.CoolUtil;
import utils.helpers.CoolVars;
import utils.helpers.Paths;

import sys.io.File;

import sys.FileSystem;

using StringTools;