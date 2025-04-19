package scripting.lua;

class LuaTween extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('tween', function(tag:String, vars:String, valueTypes:Dynamic, duration:Float, ?ease:String = 'linear')
            {
                var types = {};

                for (field in Reflect.fields(valueTypes))
                    Reflect.setField(types, field, Reflect.field(valueTypes, field));

                return tweenFunction(tag, vars, types, duration, ease);
            }
        );

        set('cancelTween', cancelTween);

        set('setProperty', (tag:String, properties:Dynamic) ->
        {
            var obj = LuaReflect.parseVariable(lua, tag);

            if (obj != null)
                applyProps(obj, properties);
        });
    }

    function applyProps(obj:Dynamic, props:Dynamic):Void
    {
        for (key in Reflect.fields(props))
        {
            var value = Reflect.field(props, key);

            if (Reflect.isObject(value))
            {
                var subObj = Reflect.field(obj, key);

                if (subObj == null)
                {
                    subObj = {};
                    
                    Reflect.setProperty(obj, key, subObj);
                }

                applyProps(subObj, value);
            } else {
                Reflect.setProperty(obj, key, value);
            }
        }
    }

    function tweenFunction(tag:String, vars:String, tweenValue:Dynamic, duration:Float, ease:String)
    {
        var target:Dynamic = tweenPrepare(tag, vars);

        if (target != null)
        {
            if (tag != null)
            {
                var ogTag:String = tag;

                tag = LuaReflect.formatVariable('tween_' + tag);

                setTag(tag, FlxTween.tween(target, tweenValue, duration, {ease: easeByString(ease),
                        onComplete: function(twn:FlxTween)
                        {
                            variables.remove(tag);

                            if (type == STATE)
                            {
                                if (ScriptState.instance != null)
                                    ScriptState.instance.callOnLuaScripts('onTweenCompleted', [ogTag, vars]);
                            } else {
                                if (ScriptSubState.instance != null)
                                    ScriptSubState.instance.callOnLuaScripts('onTweenCompleted', [ogTag, vars]);
                            }
                        }
                    })
                );
            } else {
                FlxTween.tween(target, tweenValue, duration, {ease: easeByString(ease)});
            }

            return tag;
        } else {
            errorPrint('Objects doesn\'t Exists: ' + vars);
        }

        return null;
    }

    function tweenPrepare(tag:String, vars:String)
    {
        if (tag != null)
            cancelTween(tag);

        return LuaReflect.parseVariable(lua, vars);
    }

    function cancelTween(tag:String)
    {
        if (!tag.startsWith('tween_'))
            tag = 'tween_' + LuaReflect.formatVariable(tag);

        var tween:FlxTween = variables.get(tag);

        if (tween != null)
        {
            tween.cancel();
            tween.destroy();

            variables.remove(tag);
        }
    }

	public static function easeByString(?ease:String = '')
    {
		return switch(ease.toLowerCase().trim())
        {
			case 'backin':
				FlxEase.backIn;
			case 'backinout':
				FlxEase.backInOut;
			case 'backout':
				FlxEase.backOut;
			case 'bouncein':
				FlxEase.bounceIn;
			case 'bounceinout':
				FlxEase.bounceInOut;
			case 'bounceout':
				FlxEase.bounceOut;
			case 'circin':
				FlxEase.circIn;
			case 'circinout':
				FlxEase.circInOut;
			case 'circout':
				FlxEase.circOut;
			case 'cubein':
				FlxEase.cubeIn;
			case 'cubeinout':
				FlxEase.cubeInOut;
			case 'cubeout':
				FlxEase.cubeOut;
			case 'elasticin':
				FlxEase.elasticIn;
			case 'elasticinout':
				FlxEase.elasticInOut;
			case 'elasticout':
				FlxEase.elasticOut;
			case 'expoin':
				FlxEase.expoIn;
			case 'expoinout':
				FlxEase.expoInOut;
			case 'expoout':
				FlxEase.expoOut;
			case 'quadin':
				FlxEase.quadIn;
			case 'quadinout':
				FlxEase.quadInOut;
			case 'quadout':
				FlxEase.quadOut;
			case 'quartin':
				FlxEase.quartIn;
			case 'quartinout':
				FlxEase.quartInOut;
			case 'quartout':
				FlxEase.quartOut;
			case 'quintin':
				FlxEase.quintIn;
			case 'quintinout':
				FlxEase.quintInOut;
			case 'quintout':
				FlxEase.quintOut;
			case 'sinein':
				FlxEase.sineIn;
			case 'sineinout':
				FlxEase.sineInOut;
			case 'sineout':
				FlxEase.sineOut;
			case 'smoothstepin':
				FlxEase.smoothStepIn;
			case 'smoothstepinout':
				FlxEase.smoothStepInOut;
			case 'smoothstepout':
				FlxEase.smoothStepOut;
			case 'smootherstepin':
				FlxEase.smootherStepIn;
			case 'smootherstepinout':
				FlxEase.smootherStepInOut;
			case 'smootherstepout':
				FlxEase.smootherStepOut;
			default:
				FlxEase.linear;
		}
	}
}