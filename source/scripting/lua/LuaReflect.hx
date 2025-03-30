package scripting.lua;

import Type.ValueType;

import haxe.Constraints;
import haxe.ds.StringMap;

class LuaReflect extends LuaPresetBase
{
	static final instanceStr:Dynamic = "##LUA_STRINGTOOBJ";

    public function new(lua:LuaScript)
    {
        super(lua);

        set("getProperty", function(variable:String, ?allowMaps:Bool = false)
            {
                var split:Array<String> = variable.split('.');

                if (split.length > 1)
                    return getVarInArray(getPropertyLoop(split, true, allowMaps), split[split.length-1], allowMaps);

                return getVarInArray(game, variable, allowMaps);
            }
        );

        set("setProperty", function(variable:String, value:Dynamic, allowMaps:Bool = false)
            {
                var split:Array<String> = variable.split('.');

                if (split.length > 1)
                {
                    setVarInArray(getPropertyLoop(split, true, allowMaps), split[split.length-1], value, allowMaps);

                    return true;
                }

                setVarInArray(game, variable, value, allowMaps);

                return true;
            }
        );

        set("getPropertyFromClass", function(classVar:String, variable:String, ?allowMaps:Bool = false)
            {
                var myClass:Dynamic = Type.resolveClass(classVar);

                if (myClass == null)
                {
                    errorPrint('getPropertyFromClass: Class $classVar not found');

                    return null;
                }
    
                var split:Array<String> = variable.split('.');

                if (split.length > 1)
                {
                    var obj:Dynamic = getVarInArray(myClass, split[0], allowMaps);

                    for (i in 1...split.length-1)
                        obj = getVarInArray(obj, split[i], allowMaps);
    
                    return getVarInArray(obj, split[split.length-1], allowMaps);
                }

                return getVarInArray(myClass, variable, allowMaps);
            }
        );

        set("setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false)
            {
                var myClass:Dynamic = Type.resolveClass(classVar);

                if (myClass == null)
                {
                    errorPrint('getPropertyFromClass: Class $classVar not found');

                    return null;
                }
    
                var split:Array<String> = variable.split('.');

                if (split.length > 1)
                {
                    var obj:Dynamic = getVarInArray(myClass, split[0], allowMaps);

                    for (i in 1...split.length-1)
                        obj = getVarInArray(obj, split[i], allowMaps);
    
                    setVarInArray(obj, split[split.length-1], value, allowMaps);

                    return value;
                }

                setVarInArray(myClass, variable, value, allowMaps);

                return value;
            }
        );

        set("getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false)
            {
                var split:Array<String> = obj.split('.');

                var realObject:Dynamic = null;

                if (split.length > 1)
                    realObject = getPropertyLoop(split, false, allowMaps);
                else
                    realObject = Reflect.getProperty(game, obj);
    
                if (Std.isOfType(realObject, FlxTypedGroup))
                {
                    var result:Dynamic = getGroupStuff(realObject.members[index], variable, allowMaps);
                    
                    return result;
                }
    
                var leArray:Dynamic = realObject[index];

                if (leArray != null)
                {
                    var result:Dynamic = null;

                    if (Type.typeof(variable) == ValueType.TInt)
                        result = leArray[variable];
                    else
                        result = getGroupStuff(leArray, variable, allowMaps);

                    return result;
                }
                
                errorPrint("getPropertyFromGroup: Object #" + index + " from group: " + obj + " doesn't exist!");

                return null;
            }
        );

        set("setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false)
            {
                var split:Array<String> = obj.split('.');

                var realObject:Dynamic = null;

                if (split.length > 1)
                    realObject = getPropertyLoop(split, false, allowMaps);
                else
                    realObject = Reflect.getProperty(game, obj);
    
                if (Std.isOfType(realObject, FlxTypedGroup))
                {
                    setGroupStuff(realObject.members[index], variable, value, allowMaps);

                    return value;
                }
    
                var leArray:Dynamic = realObject[index];

                if (leArray != null)
                {
                    if (Type.typeof(variable) == ValueType.TInt)
                    {
                        leArray[variable] = value;

                        return value;
                    }

                    setGroupStuff(leArray, variable, value, allowMaps);
                }

                return value;
            }
        );

        set("removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false)
            {
                var groupOrArray:Dynamic = Reflect.getProperty(game, obj);

                if (Std.isOfType(groupOrArray, FlxTypedGroup))
                {
                    var obj:Dynamic = groupOrArray.members[index];

                    if (!dontDestroy)
                        obj.kill();

                    groupOrArray.remove(obj, true);

                    if (!dontDestroy)
                        obj.destroy();

                    return;
                }

                groupOrArray.remove(groupOrArray[index]);
            }
        );
            
        set("callMethod", function(funcToRun:String, ?args:Array<Dynamic> = null)
            {
                return callMethodFromObject(PlayState.instance, funcToRun, parseInstances(args));
                
            }
        );
        set("callMethodFromClass", function(className:String, funcToRun:String, ?args:Array<Dynamic> = null)
            {
                return callMethodFromObject(Type.resolveClass(className), funcToRun, parseInstances(args));
            }
        );
    
        set("createInstance", function(variableToSave:String, className:String, ?args:Array<Dynamic> = null)
            {
                variableToSave = variableToSave.trim().replace('.', '');

                if (!variables.exists(variableToSave))
                {
                    if (args == null)
                        args = [];

                    var myType:Dynamic = Type.resolveClass(className);
            
                    if (myType == null)
                    {
                        errorPrint('createInstance: Variable $variableToSave is already being used and cannot be replaced!');

                        return false;
                    }
    
                    var obj:Dynamic = Type.createInstance(myType, args);

                    if (obj != null)
                        variables.set(variableToSave, obj);
                    else
                        errorPrint('createInstance: Failed to create $variableToSave, arguments are possibly wrong.');
    
                    return (obj != null);
                } else {
                    errorPrint('createInstance: Variable $variableToSave is already being used and cannot be replaced!');
                }

                return false;
            }
        );

        set("instanceArg", function(instanceName:String, ?className:String = null)
            {
                var retStr:String ='$instanceStr::$instanceName';

                if (className != null) retStr += '::$className';

                return retStr;
            }
        );
    }
    
    function parseInstances(args:Array<Dynamic>)
    {
        for (i in 0...args.length)
        {
            var myArg:String = cast args[i];

            if (myArg != null && myArg.length > instanceStr.length)
            {
                var index:Int = myArg.indexOf('::');

                if (index > -1)
                {
                    myArg = myArg.substring(index + 2);

                    var lastIndex:Int = myArg.lastIndexOf('::');

                    var split:Array<String> = myArg.split('.');

                    args[i] = (lastIndex > -1) ? Type.resolveClass(myArg.substring(0, lastIndex)) : ScriptState.instance;

                    for (j in 0...split.length)
                        args[i] = getVarInArray(args[i], split[j].trim());
                }
            }
        }

        return args;
    }

    function callMethodFromObject(classObj:Dynamic, funcStr:String, args:Array<Dynamic> = null)
    {
        if (args == null)
            args = [];

        var split:Array<String> = funcStr.split('.');

        var funcToRun:Function = null;

        var obj:Dynamic = classObj;
        
        if (obj == null)
            return null;

        for (i in 0...split.length)
            obj = getVarInArray(obj, split[i].trim());

        funcToRun = cast obj;
        
        return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
    }

    function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
    {
        var splitProps:Array<String> = variable.split('[');

        if (splitProps.length > 1)
        {
            var target:Dynamic = null;

            if (variables.exists(splitProps[0]))
            {
                var retVal:Dynamic = variables.get(splitProps[0]);
                
                if (retVal != null)
                    target = retVal;
            } else {
                target = Reflect.getProperty(instance, splitProps[0]);
            }

            for (i in 1...splitProps.length)
            {
                var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);

                if (i >= splitProps.length-1)
                    target[j] = value;
                else
                    target = target[j];
            }

            return target;
        }

        if (allowMaps && isMap(instance))
        {
            instance.set(variable, value);

            return value;
        }

        if (variables.exists(variable))
        {
            variables.set(variable, value);

            return value;
        }

        Reflect.setProperty(instance, variable, value);

        return value;
    }

    function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
    {
        var splitProps:Array<String> = variable.split('[');

        if (splitProps.length > 1)
        {
            var target:Dynamic = null;

            if (variables.exists(splitProps[0]))
            {
                var retVal:Dynamic = variables.get(splitProps[0]);

                if (retVal != null)
                    target = retVal;
            } else {
                target = Reflect.getProperty(instance, splitProps[0]);
            }

            for (i in 1...splitProps.length)
            {
                var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);

                target = target[j];
            }

            return target;
        }
        
        if (allowMaps && isMap(instance))
            return instance.get(variable);

        if (variables.exists(variable))
        {
            var retVal:Dynamic = variables.get(variable);

            if (retVal != null)
                return retVal;
        }

        return Reflect.getProperty(instance, variable);
    }

	function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic, ?allowMaps:Bool = false) {
		var split:Array<String> = variable.split('.');

		if (split.length > 1)
        {
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);

			for (i in 1...split.length-1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;

			variable = split[split.length-1];
		}

		if (allowMaps && isMap(leArray))
            leArray.set(variable, value);
		else
            Reflect.setProperty(leArray, variable, value);

		return value;
	}
	function getGroupStuff(leArray:Dynamic, variable:String, ?allowMaps:Bool = false) {
		var split:Array<String> = variable.split('.');

		if (split.length > 1)
        {
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);

			for (i in 1...split.length-1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;

			variable = split[split.length-1];
		}

		if (allowMaps && isMap(leArray))
            return leArray.get(variable);

		return Reflect.getProperty(leArray, variable);
	}

	function getPropertyLoop(split:Array<String>,?getProperty:Bool=true, ?allowMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObjectDirectly(split[0]);

		var end = split.length;

		if (getProperty)
            end = split.length-1;

		for (i in 1...end)
            obj = getVarInArray(obj, split[i], allowMaps);

		return obj;
	}

	function isMap(variable:Dynamic)
	{
		if (variable.exists != null && variable.keyValueIterator != null)
            return true;

		return false;
	}

	function getObjectDirectly(objectName:String, ?allowMaps:Bool = false):Dynamic
	{
		switch(objectName)
		{
			case 'this' | 'instance' | 'game':
				return PlayState.instance;
			
			default:
				var obj:Dynamic = variables.get(objectName);

				if (obj == null)
                    obj = getVarInArray(game, objectName, allowMaps);

				return obj;
		}
	}
}