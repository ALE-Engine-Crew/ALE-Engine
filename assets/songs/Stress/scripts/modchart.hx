CoolUtil.resizeGame(1280, 720);

function onCreatePost()
{
    var oso:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    oso.alpha = 0.5;
    add(oso);
    oso.cameras = [game.camGame];
}