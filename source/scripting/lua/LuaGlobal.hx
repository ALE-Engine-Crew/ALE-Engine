package scripting.lua;

import flixel.FlxBasic;
import flixel.FlxObject;

class LuaGlobal extends LuaPresetBase
{
    public function new(lua:LuaScript)
    {
        super(lua);

        set('add', function(tag:String)
        {
            if (tagIs(tag, FlxBasic))
                game.add(getTag(tag));
        });

        set('remove', function(tag:String)
            {
                if (game.members.indexOf(getTag(tag)) != -1)
                    game.remove(getTag(tag));
                else
                    errorPrint('Object ' + tag + ' Has Not Been Added Yet');
            }
        );

        set('insert', function(position:Int, tag:String)
            {
                if (tagIs(tag, FlxBasic))
                    game.insert(position, getTag(tag));
            }
        );

        set('setObjectCameras', function(tag:String, cameras:Array<String>)
            {
                var theCameras:Array<FlxCamera> = [];

                for (cam in cameras)
                    theCameras.push(cameraFromString(cam));

                if (tagIs(tag, FlxObject))
                {
                    var object:FlxObject = cast(getTag(tag), FlxObject);

                    object.cameras = theCameras;
                }
            }
        );

        set('debugPrint', function(text:String, ?color:String)
        {
            game.debugPrint(text, color == null ? null : CoolUtil.colorFromString(color));
        });
    }

    private function cameraFromString(name:String):FlxCamera
    {
        var result:FlxCamera = switch(name.toUpperCase())
        {
            case 'CAMERA', 'CAMGAME', 'CAMERAGAME':
                game.camGame;
            case 'HUD', 'CAMHUD', 'CAMERAHUD':
                game.camHUD;
            case 'OTHER', 'CAMOTHER', 'CAMERAOTHER':
                game.camOther;
            default:
                null;
        };

        if (result == null)
            errorPrint(name + ' is Not a Camera');

        return result;
    }
}