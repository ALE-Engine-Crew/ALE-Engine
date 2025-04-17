import flixel.util.FlxGradient;

import funkin.visuals.objects.AttachedSprite;

var transBlack:FlxSprite;
var transGradient:FlxSprite;

function onCreate()
{
	transGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, (transOut ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
	transGradient.scrollFactor.set();
	add(transGradient);
	transGradient.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

	transBlack = new AttachedSprite().makeGraphic(FlxG.width, FlxG.height + (transIn ? 400 : 0), FlxColor.BLACK);
	transBlack.scrollFactor.set();
	add(transBlack);
	transBlack.sprTracker = transGradient;
	transBlack.yAdd = transIn ? -transBlack.height : transGradient.height; 
	transBlack.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

	transGradient.y = -transGradient.height;
}

function onUpdate(elapsed:Float)
{
	transGradient.y += (transGradient.height + FlxG.height) * elapsed / 0.5;

	if (transGradient.y >= FlxG.height)
		close();
}