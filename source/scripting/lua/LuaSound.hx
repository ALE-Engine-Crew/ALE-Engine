package scripting.lua;

class LuaSound extends LuaPresetBase
{
    override public function new(lua)
    {
        super(lua);

        set('newSound', function(tag:String, sound:String)
            {
                var soundObj:FlxSound = new FlxSound();
                soundObj.loadEmbedded(Paths.sound(sound));
                FlxG.sound.list.add(soundObj);

                setTag(tag, soundObj);
            }
        );

        set('playSound', function(tag:String)
            {
                if (tagIs(tag, FlxSound))
                    getTag(tag).play();
            }
        );

        set('pauseSound', function(tag:String)
            {
                if (tagIs(tag, FlxSound))
                    getTag(tag).pause();
            }
        );

        set('resumeSound', function(tag:String)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).resume();
        });

        set('stopSound', function(tag:String)
            {
                if (tagIs(tag, FlxSound))
                    getTag(tag).stop();
            }
        );
        
        set('playMusic', function(sound:String)
            {
                FlxG.sound.playMusic(Paths.music(sound));
            }
        );

        set('pauseMusic', function()
            {
                if (FlxG.sound.music != null)
                    FlxG.sound.music.pause();
            }
        );

        set('resumeMusic', function()
            {
                if (FlxG.sound.music != null)
                    FlxG.sound.music.resume();
            }
        );

        set('stopMusic', function()
            {
                if (FlxG.sound.music != null)
                    FlxG.sound.music.stop();
            }
        );
    }
}