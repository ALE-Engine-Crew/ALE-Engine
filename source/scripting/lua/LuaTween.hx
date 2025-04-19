package scripting.lua;

class LuaTween extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('tween', function(tag:String, vars:String, valueType:String, value:Dynamic, duration:Float, ?ease:String = 'linear')
            {
                if (valueType.toLowerCase().trim() == 'zoom')
                {
                    vars = switch (vars.toLowerCase())
                    {
                        case 'camera', 'camgame', 'cameragame':
                            'camGame';
                        case 'hud', 'camhud', 'camerahud':
                            'camHUD';
                        default:
                            'camGame';
                    }

                    return tweenFunction(tag, vars, {zoom: value}, duration, ease);
                } else {
                    return tweenFunction(tag, vars,
                        switch (valueType.toLowerCase().trim())
                        {
                            default:
                                {x: value}
                            case 'y':
                                {y: value}
                            case 'angle':
                                {angle: value}
                            case 'alpha':
                                {alpha: value}
                        },
                    duration, ease);
                }
            }
        );
    }

    function tweenFunction(tag:String, vars:String, tweenValue:Any, duration:Float, ease:String)
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

        var variables:Array<String> = vars.split('.');
        var prop:Dynamic = LuaReflect.getObjectDirectly(lua, variables[0]);

        if (variables.length > 1)
            prop = LuaReflect.getVarInArray(lua, LuaReflect.getPropertyLoop(lua, variables), variables[variables.length - 1]);

        return prop;
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
		switch(ease.toLowerCase().trim())
        {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}