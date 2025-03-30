package scripting.lua;

import llua.State;

import llua.Lua;
import llua.LuaL;

import llua.Lua.Lua_helper;

import llua.Convert;

class LuaCallbackHandler
{
    public static inline function call(lua:State, functionName:String):Int
    {
        try
        {
            var callFunc:Dynamic = Lua_helper.callbacks.get(functionName);

            if (callFunc == null)
            {
                var last:LuaScript = LuaScript.lastCalledScript;

                if (last == null || last.lua != lua)
                {
                    for (script in ScriptState.instance.luaScripts)
                    {
                        if (script != LuaScript.lastCalledScript && script != null && script.lua == lua)
                        {
                            callFunc = script.callbacks.get(functionName);

                            break;
                        }
                    }
                } else {
                    callFunc = last.callbacks.get(functionName);
                }
            }

            if (callFunc == null)
                return 0;

			var numberOfParams:Int = Lua.gettop(lua);
			var args:Array<Dynamic> = [];

			for (i in 0...numberOfParams)
				args[i] = Convert.fromLua(lua, i + 1);

			var returnValue:Dynamic = null;

			returnValue = Reflect.callMethod(null, callFunc, args);

			if (returnValue != null)
            {
				Convert.toLua(lua, returnValue);

				return 1;
			}
        } catch (error:Dynamic) {
            if (Lua_helper.sendErrorsToLua)
            {
                LuaL.error(lua, 'Callback Error: ' + (error.message != null ? error.message : error));
                
                return 0;
            }

            trace(error);

            throw(error);
        }

        return 0;
    }
}