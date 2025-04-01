package funkin.visuals.objects;

import core.enums.ALECharacterType;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSpriteGroup
{
    public var sprite:FlxSprite;
    public var splash:FlxSprite;

    public var botplay(default, set):Bool = false;

    function set_botplay(value:Bool):Bool
    {
        botplay = value;

        if (type == PLAYER)
        {
            if (sprite != null)
            {
                if (botplay)
                {
                    sprite.animation.finishCallback = (name:String) -> {
                        sprite.animation.play('idle');
                    }
                } else {
                    sprite.animation.play('idle', true);

                    sprite.animation.finishCallback = (name:String) -> {}
                }
            }
        }

        return botplay;
    }

    public var scrollSpeed:Float = 1;

    public var noteData:Int;

    public var type:ALECharacterType;

    public var texture(default, set):String = 'note';

    public var direction:Float = 90;

    var shaderRef:RGBShaderReference;

    var splashShaderRef:RGBShaderReference;

    function set_texture(value:String):String
    {
        texture = value;

        loadTexture(texture);

        return texture;
    }

    public var splashTexture(default, set):String = 'splash';

    function set_splashTexture(value:String):String
    {
        splashTexture = value;

        loadSplashTexture(splashTexture);

        return splashTexture;
    }

	override public function new(noteData:Int, type:ALECharacterType, ?texture:String = 'note', ?splashTexture:String = 'splash')
	{
		super();

        this.noteData = noteData;

        this.type = type;

        antialiasing = ClientPrefs.data.antialiasing;

        sprite = new FlxSprite();
        add(sprite);

        this.texture = texture;

        splash = new FlxSprite();
        add(splash);

        splash.visible = false;

        splash.scale.x = splash.scale.y = 1 / 0.7;

        this.splashTexture = splashTexture;

        x = 160 * 0.7 * noteData;

        if (type == OPPONENT)
            x += 50;
        else
            x += FlxG.width - (160 * 0.7 * 5) + 50;

        y = 50;

        var rgbPalette = new RGBPalette();

        shaderRef = new RGBShaderReference(sprite, rgbPalette);

        splashShaderRef = new RGBShaderReference(splash, rgbPalette);

        var shaderArray:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % 4];
        
        shaderRef.r = splashShaderRef.r = shaderArray[0];
        shaderRef.g = splashShaderRef.g = shaderArray[1];
        shaderRef.b = splashShaderRef.b = shaderArray[2];

        sprite.antialiasing = splash.antialiasing = ClientPrefs.data.antialiasing;

        scale.x = scale.y = 0.7;

        updateHitbox();
	}

    public function loadTexture(image:String)
    {
        sprite.frames = Paths.getSparrowAtlas('notes/' + image);

        var animToPlay:String = switch (noteData % 4)
        {
            case 0: 'left';
            case 1: 'down';
            case 2: 'up';
            case 3: 'right';
            default: null;
        };

        sprite.animation.addByPrefix('idle', 'arrow' + animToPlay.toUpperCase(), 24, false);
        sprite.animation.addByPrefix('pressed', animToPlay + ' press', 24, false);
        sprite.animation.addByPrefix('hit', animToPlay + ' confirm', 24, false);

        sprite.animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
            sprite.centerOffsets();
            sprite.centerOrigin();

            if (shaderRef != null)
                shaderRef.enabled = name != 'idle';
        }

        sprite.animation.finishCallback = (name:String) -> {
            if (name == 'hit' && type != PLAYER)
                sprite.animation.play('idle');
        }
        
        sprite.animation.play('idle');

        sprite.centerOffsets();
        sprite.centerOrigin();

        sprite.updateHitbox();
    }

    function loadSplashTexture(image:String)
    {
        splash.frames = Paths.getSparrowAtlas('splashes/' + image);

        switch (noteData % 4)
        {
            case 0:
                splash.animation.addByPrefix('splash', 'note splash purple 1', 24, false);
            case 1:
                splash.animation.addByPrefix('splash', 'note splash blue 1', 24, false);
            case 2:
                splash.animation.addByPrefix('splash', 'note splash green 1', 24, false);
            case 3:
                splash.animation.addByPrefix('splash', 'note splash red 1', 24, false);
        }

        splash.animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {
            splash.centerOffsets();
            splash.centerOrigin();
            
            splash.visible = true;
        }

        splash.animation.finishCallback = (name:String) -> {
            splash.visible = false;
        }

        splash.centerOffsets();
        splash.centerOrigin();

        splash.updateHitbox();

        splash.x = sprite.width / 2 - width / 2;
        splash.y = sprite.height / 2 - height / 2;
    }
}