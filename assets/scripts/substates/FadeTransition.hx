import flixel.util.FlxGradient;

var transBlack:FlxSprite;
var transGradient:FlxSprite;

function onCreate()
{
	transGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, (transOut ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
	transGradient.scrollFactor.set();
	add(transGradient);
	transGradient.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

	transBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height + (transIn ? 400 : 0), FlxColor.BLACK);
	transBlack.scrollFactor.set();
	add(transBlack);
	transBlack.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

	transGradient.y = -transGradient.height;
}

function onUpdate(elapsed:Float)
{
	transGradient.y += (transGradient.height + FlxG.height) * elapsed / 0.5;
	
	transBlack.y = transGradient.y + (transIn ? -1 : 1) * transBlack.height; 

	if (transGradient.y >= FlxG.height)
		close();
}