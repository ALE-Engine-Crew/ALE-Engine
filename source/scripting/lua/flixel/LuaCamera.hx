package scripting.lua.flixel;

import flixel.FlxObject;

class LuaCamera extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('newCamera', function(tag:String, x:Float = 0, y:Float = 0, width:Int = 0, heigth:Int = 0, zoom:Float = 0)
            {
                setTag(tag, new FlxCamera(x, y, width, heigth, zoom));
            }
        );

        set('addCamera', function(tag:String, ?defaultDraw:Bool)
            {
                FlxG.cameras.add(cameraFromString(lua, tag), defaultDraw);
            }
        );

        set('removeCamera', function(tag:String)
            {
                if (FlxG.cameras.list.indexOf(cameraFromString(lua, tag)) != -1)
                        FlxG.cameras.remove(cameraFromString(lua, tag));
            }
        );

        set('bindCameraScrollPos', function(tag:String, x:Float, y:Float)
            {
                cameraFromString(lua, tag).bindScrollPos(new FlxPoint(x, y));
            }
        );

        set('cameraContainsPoint', function(tag:String, x:Float, y:Float, width:Float, height:Float)
            {
                cameraFromString(lua, tag).containsPoint(new FlxPoint(x, y), width, height);
            }
        );

        set('cameraCopyFrom', function(tag:String, copyTag:String)
            {
                cameraFromString(lua, tag).copyFrom(cameraFromString(lua, copyTag));
            }
        );

        set('fadeCamera', function(tag:String, ?color:FlxColor, ?duration:Float, ?fadeIn:Bool, ?onComplete:Void -> Void, ?force:Bool)
            {
                cameraFromString(lua, tag).fade(color, duration, fadeIn, onComplete, force);
            }
        );

        set('flashCamera', function(tag:String, ?color:FlxColor, ?duration:Float, ?onComplete:Void -> Void, ?force:Bool)
            {
                cameraFromString(lua, tag).flash(color, duration, onComplete, force);
            }
        );

        set('focusCameraOn', function(tag:String, x:Float, y:Float)
            {
                cameraFromString(lua, tag).focusOn(new FlxPoint(x, y));
            }
        );

        set('cameraFollow', function(tag:String, target:String, ?lerp:Float)
            {
                if (tagIs(target, FlxObject))
                    cameraFromString(lua, tag).follow(getTag(target), null, lerp);
            }
        );

        set('setCameraScrollBounds', function(tag:String, minX:Null<Float>, maxX:Null<Float>, minY:Null<Float>, maxY:Null<Float>)
            {
                cameraFromString(lua, tag).setScrollBounds(minX, maxX, minY, maxY);
            }
        );

        set('setCameraScrollBoundsRect', function(tag:String, ?x:Float, ?y:Float, ?width:Float, ?height:Float, ?updateWorld:Bool)
            {
                cameraFromString(lua, tag).setScrollBoundsRect(x, y, width, height, updateWorld);
            }
        );

        set('shakeCamera', function(tag:String, ?intensity:Float, ?duration:Float, ?onComplete:Void -> Void, ?force:Bool)
            {
                cameraFromString(lua, tag).shake(intensity, duration, onComplete, force);
            }
        );

        set('snapCameraToTarget', function(tag:String)
            {
                cameraFromString(lua, tag).snapToTarget();
            }
        );

        set('stopCameraFX', function(tag:String)
            {
                cameraFromString(lua, tag).stopFX();
            }
        );

        set('stopCameraFade', function(tag:String)
            {
                cameraFromString(lua, tag).stopFade();
            }
        );

        set('stopCameraFlash', function(tag:String)
            {
                cameraFromString(lua, tag).stopFlash();
            }
        );

        set('stopCameraShake', function(tag:String)
            {
                cameraFromString(lua, tag).stopShake();
            }
        );
    }

    public static function cameraFromString(lua:LuaScript, name:String):FlxCamera
    {
        if (lua.variables.exists(name))
            if (lua.variables.get(name) is FlxCamera)
                return lua.variables.get(name);

        var result:FlxCamera = null;
        
        if (lua.type == STATE)
        {
            result = switch(name.toUpperCase())
            {
                case 'HUD', 'CAMHUD', 'CAMERAHUD':
                    ScriptState.instance.camHUD;
                default:
                    ScriptState.instance.camGame;
            };
        } else {
            result = switch(name.toUpperCase())
            {
                default:
                    ScriptSubState.instance.camGame;
            };
        }

        return result;
    }
}