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
                    ScriptState.instance.add(getTag(tag));
                else
                    ScriptSubState.instance.add(getTag(tag));
            }
        });

        set('remove', function(tag:String)
            {
                if (type == STATE)
                {
                    if (ScriptState.instance.members.indexOf(getTag(tag)) != -1)
                        ScriptState.instance.remove(getTag(tag));
                    else
                        errorPrint('Object ' + tag + ' Has Not Been Added Yet');
                } else {
                    if (ScriptSubState.instance.members.indexOf(getTag(tag)) != -1)
                        ScriptSubState.instance.remove(getTag(tag));
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
                        ScriptState.instance.insert(position, getTag(tag));
                } else {
                    if (tagIs(tag, FlxBasic))
                        ScriptSubState.instance.insert(position, getTag(tag));
                }
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
            if (type == STATE)
                ScriptState.instance.debugPrint(text, color == null ? null : CoolUtil.colorFromString(color));
            else
                ScriptSubState.instance.debugPrint(text, color == null ? null : CoolUtil.colorFromString(color));
        });

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
            set('close', ScriptSubState.instance.close);
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