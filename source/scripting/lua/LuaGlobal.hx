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
            {
                if (type == STATE)
                    FlxG.state.add(getTag(tag));
                else
                    FlxG.state.subState.add(getTag(tag));
            }
        });

        set('remove', function(tag:String)
            {
                if (type == STATE)
                {
                    if (FlxG.state.members.indexOf(getTag(tag)) != -1)
                        FlxG.state.remove(getTag(tag));
                    else
                        errorPrint('Object ' + tag + ' Has Not Been Added Yet');
                } else {
                    if (FlxG.state.subState.members.indexOf(getTag(tag)) != -1)
                        FlxG.state.subState.remove(getTag(tag));
                    else
                        errorPrint('Object ' + tag + ' Has Not Been Added Yet');
                }
            }
        );

        set('insert', function(position:Int, tag:String)
            {
                if (type == STATE)
                {
                    if (tagIs(tag, FlxBasic))
                        FlxG.state.insert(position, getTag(tag));
                } else {
                    if (tagIs(tag, FlxBasic))
                        FlxG.state.subState.insert(position, getTag(tag));
                }
            }
        );

        set('debugPrint', function(text:Dynamic, ?color:FlxColor)
        {
            if (type == STATE)
                ScriptState.instance.debugPrint(text, color);
            else
                ScriptSubState.instance.debugPrint(text, color);
        });

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

        set('switchState', function(fullClassPath:String, params:Array<Dynamic>)
		{
			CoolUtil.switchState(Type.createInstance(Type.resolveClass(fullClassPath), params));
		});

        set('switchToCustomState', function(name:String)
		{
			CoolUtil.switchState(new CustomState(name));
		});

        if (type == STATE)
        {
            set('openSubState', function(fullClassPath:String, params:Array<Dynamic>)
            {
                CoolUtil.openSubState(Type.createInstance(Type.resolveClass(fullClassPath), params));
            });

            set('openCustomSubState', function(name:String)
            {
                CoolUtil.openSubState(new CustomSubState(name));
            });
        }

        if (type == SUBSTATE)
        {
            set('close', FlxG.state.subState.close);
        }
    }

    private function cameraFromString(name:String):FlxCamera
    {
        var result:FlxCamera = null;
        
        if (type == STATE)
        {
            result = switch(name.toUpperCase())
            {
                case 'CAMERA', 'CAMGAME', 'CAMERAGAME':
                    ScriptState.instance.camGame;
                case 'HUD', 'CAMHUD', 'CAMERAHUD':
                    ScriptState.instance.camHUD;
                case 'OTHER', 'CAMOTHER', 'CAMERAOTHER':
                    ScriptState.instance.camOther;
                default:
                    null;
            };
        } else {
            result = switch(name.toUpperCase())
            {
                case 'CAMERA', 'CAMGAME', 'CAMERAGAME':
                    ScriptSubState.instance.camGame;
                default:
                    null;
            };
        }

        if (result == null)
            errorPrint(name + ' is Not a Camera');

        return result;
    }
}