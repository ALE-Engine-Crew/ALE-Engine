package other;

import flixel.util.FlxSort;

class NoteGroup extends FlxTypedGroup<Note>
{
    var i:Int = 0;

    var loopSprite:Note;

    override public function update(elapsed:Float)
    {
        i = length - 1;

        loopSprite = null;

        while (i >= 0)
        {
            loopSprite = members[i--];

            if (loopSprite == null || !loopSprite.exists || !loopSprite.visible)
                continue;

            loopSprite.update(elapsed);
        }
    }

    override public function draw()
    {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
        
		@:privateAccess if (cameras != null)
            FlxCamera._defaultCameras = cameras;

        i = length - 1;

        while (i >= 0)
        {
            loopSprite = members[i--];

            if (loopSprite == null || !loopSprite.exists || !loopSprite.visible)
                continue;

            loopSprite.draw();
        }

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
    }
}