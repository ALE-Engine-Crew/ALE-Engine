package funkin.visuals.objects;

import openfl.events.MouseEvent;

class StrumControl extends FlxSprite
{
    public final callback:Int -> Void;
    public final releaseCallback:Int -> Void;

    public final noteData:Int;

    override public function new(noteData:Int, callback:Int -> Void, releaseCallback:Int -> Void)
    {
        super();

        this.callback = callback;
        this.releaseCallback = releaseCallback;

        this.noteData = noteData;

        makeGraphic(Math.floor(FlxG.width / 4), FlxG.height, FlxColor.GRAY);

        FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseReleased);

        x = FlxG.width / 4 * noteData;
    }

    function onMousePressed(_)
    {
        if (!FlxG.mouse.overlaps(this))
            return;

        alpha = 0.5;

        callback(noteData);
    }

    function onMouseReleased(_)
    {
        releaseCallback(noteData);
    }

    override function destroy()
    {
        FlxG.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
        FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseReleased);

        super.destroy();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        alpha = CoolUtil.fpsLerp(alpha, 0.125, 0.1);
    }
}