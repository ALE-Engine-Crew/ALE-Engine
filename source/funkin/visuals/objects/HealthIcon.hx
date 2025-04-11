package funkin.visuals.objects;

import flixel.graphics.FlxGraphic;

/**
 * It is an extension of FlxSprite that handles Icons
 */
class HealthIcon extends FlxSprite
{
    public var anims:Int = 2;

    override public function new(name:String, ?anims:Int = 2)
    {
        super();

        if (anims < 1) anims = 1;
        this.anims = anims;

        changeIcon(name);

        antialiasing = ClientPrefs.data.antialiasing;
    }

    public function changeIcon(char:String)
    {
        var name:String = 'icons/' + char;

        if (!Paths.fileExists('images/' + name + '.png'))
            name = 'icons/icon-' + char;

        if (!Paths.fileExists('images/' + name + '.png'))
            name = 'icons/face';

        var animsArray:Array<Int> = [];

        for (i in 0...anims)
            animsArray.push(i);
        
        var graphic:FlxGraphic = Paths.image(name);

        loadGraphic(graphic, true, Math.floor(graphic.width / anims), Math.floor(graphic.height));

        animation.add(char, animsArray, 0, false);
        animation.play(char);

        updateHitbox();
    }
}