

package utils.scripting.lua;

import llua.*;
import llua.Lua.Lua_helper;

import haxe.ds.StringMap;

class LuaScript
{   
    public var lua:State = null;

    public var name:String;

    public var closed:Bool = false;

    public var callbacks:StringMap<Dynamic> = new StringMap<Dynamic>();

    public function new(name:String)
    {
        this.name = name;

        create();
    }

    function create()
    {
        lua = LuaL.newstate();
        LuaL.openlibs(lua);
        LuaL.dofile(lua, name);
    }

    public function set(name:String, value:Dynamic)
    {
        if (lua == null || closed)
            return;

        Convert.toLua(lua, value);
        Lua.setglobal(lua, name);
    }
    
    public function setFunction(name:String, theFunction:Dynamic)
    {
        if (closed)
            return;

        callbacks.set(name, theFunction);
        Lua_helper.add_callback(lua, name, null);
    }

    public var lastCalledFunction:String = '';
    public static var lastCalledScript:LuaScript = null;

    public function call(name:String, ?args:Array<Dynamic>):Dynamic
    {
        if (closed)
            return null;

        try
        {
            if (lua == null)
                return null;

            Lua.getglobal(lua, name);

            var type:Int = Lua.type(lua, -1);

            if (type != Lua.LUA_TFUNCTION)
            {
                if (type > Lua.LUA_TFUNCTION)
                    debugPrint('Error: (' + name + '): Attempt to Call a ' + typeToString(type) + ' value', FlxColor.RED);

                Lua.pop(lua, 1);
                
                return null;
            }
            
            if (args != null)
                for (arg in args)
                    Convert.toLua(lua, arg);

            var status:Int = Lua.pcall(lua, args == null ? 0 : args.length, 1, 0);

            if (status != Lua.LUA_OK)
            {
                debugPrint('Error (' + name + '): ' + getError(status), FlxColor.RED);

                return null;
            }

            var result:Dynamic = cast Convert.fromLua(lua, -1);

            if (result == null)
                return null;

            Lua.pop(lua, -1);

            if (closed)
                close();

            return result;
        } catch (error:Dynamic) {
            debugPrint(error);
        }

        return null;
    }

    public function close()
    {
        closed = true;

        if (lua == null || closed)
            return;

        Lua.close(lua);
    }

    private var debugPrint = MusicBeatState.instance.debugPrint;

    private function typeToString(type:Int):String
    {
        return switch (type)
        {
            case Lua.LUA_TBOOLEAN: 'bool';
            case Lua.LUA_TNUMBER: 'number';
            case Lua.LUA_TSTRING: 'string';
            case Lua.LUA_TTABLE: 'table';
            case Lua.LUA_TFUNCTION: 'function';
            case Lua.LUA_TNIL: 'null';
            default: 'unknown';
        }
    }

    private function getError(status:Int):String
    {
        var value:String = Lua.tostring(lua, -1);

        Lua.pop(lua, 1);

        if (value != null)
            value = value.trim();

        if (value == null || value == '')
        {
            return switch (status)
            {
                case Lua.LUA_ERRRUN: 'Runtime Error';
                case Lua.LUA_ERRMEM: 'Memory Allocation Error';
                case Lua.LUA_ERRERR: 'Critical Error';
                default: 'Unknown Error';
            }
        }

        return value;

        return null;
    }
}


/*
package utils.scripting.lua;

import llua.*;
import llua.Lua.Lua_helper;

class LuaScript {
	public var lua:State = null;
	public var name:String = '';
	public var closed:Bool = false;

	public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(name:String) {
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		//LuaL.dostring(lua, CLENSE);

		this.name = name.trim();
        
		Lua_helper.add_callback(lua, "debugPrint", MusicBeatState.instance.debugPrint);

		setFunction("close", function() {
			closed = true;
			trace('Closing script $name');
			return closed;
		});

		try
        {
			var isString:Bool = !FileSystem.exists(name);
			var result:Dynamic = null;
			if(!isString)
				result = LuaL.dofile(lua, name);
			else
				result = LuaL.dostring(lua, name);

			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace(resultStr);
				MusicBeatState.instance.debugPrint('$name\n$resultStr', FlxColor.RED);
				lua = null;
				return;
			}
			if(isString) name = 'unknown';
		} catch(e:Dynamic) {
			trace(e);
			return;
		}
		trace('lua file loaded succesfully:' + name);

		call('onCreate', []);
	}

	//main
	public var lastCalledFunction:String = '';
	public static var lastCalledScript:LuaScript = null;
	public function call(func:String, args:Array<Dynamic>):Dynamic {
		if(closed) return 'oso';

		lastCalledFunction = func;
		lastCalledScript = this;
		try {
			if(lua == null) return 'oso';

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION) {
				if (type > Lua.LUA_TNIL)
					MusicBeatState.instance.debugPrint("ERROR (" + func + "): attempt to call a " + typeToString(type) + " value", FlxColor.RED);

				Lua.pop(lua, 1);
				return 'oso';
			}

			for (arg in args) Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK) {
				var error:String = getErrorMessage(status);
				MusicBeatState.instance.debugPrint("ERROR (" + func + "): " + error, FlxColor.RED);
				return 'oso';
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null) result = 'oso';

			Lua.pop(lua, 1);
			if(closed) close();
			return result;
		}
		catch (e:Dynamic) {
			trace(e);
		}
		return 'oso';
	}

    private function typeToString(type:Int):String
    {
        return switch (type)
        {
            case Lua.LUA_TBOOLEAN: 'bool';
            case Lua.LUA_TNUMBER: 'number';
            case Lua.LUA_TSTRING: 'string';
            case Lua.LUA_TTABLE: 'table';
            case Lua.LUA_TFUNCTION: 'function';
            case Lua.LUA_TNIL: 'null';
            default: 'unknown';
        }
    }

	public function set(variable:String, data:Dynamic) {
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function close() {
		closed = true;

		if(lua == null) {
			return;
		}
		Lua.close(lua);
		lua = null;
	}

	public function getErrorMessage(status:Int):String {
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null) v = v.trim();
		if (v == null || v == "") {
			switch(status) {
				case Lua.LUA_ERRRUN: return "Runtime Error";
				case Lua.LUA_ERRMEM: return "Memory Allocation Error";
				case Lua.LUA_ERRERR: return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		return null;
	}

	public function setFunction(name:String, myFunction:Dynamic)
	{
		callbacks.set(name, myFunction);
		Lua_helper.add_callback(lua, name, myFunction); //just so that it gets called
	}
}
    */