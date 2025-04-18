package core.backend;

import scripting.haxe.HScript;

import scripting.lua.LuaScript;

class ScriptState extends MusicBeatState
{
    public static var instance:ScriptState;

    override public function new()
    {
        super();
    }

    #if HSCRIPT_ALLOWED
    public var hScripts:Array<HScript> = [];
    #end

    #if LUA_ALLOWED
    public var luaScripts:Array<LuaScript> = [];
    #end

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

    override public function create()
    {
        super.create();
        
        instance = this;
        
		camGame = CoolUtil.initALECamera();

		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;
		
		FlxG.cameras.add(camHUD, false);
    }

    override public function destroy()
    {
        instance = null;

        super.destroy();
    }

    public inline function loadScript(path:String)
    {
        #if HSCRIPT_ALLOWED
        if (path.endsWith('.hx'))
        {
            loadHScript(path.substring(0, path.length - 3));

            return;
        }
        #end

        #if LUA_ALLOWED
        if (path.endsWith('.lua'))
        {
            loadLuaScript(path.substring(0, path.length - 4));

            return;
        }
        #end

        #if HSCRIPT_ALLOWED
        loadHScript(path);
        #end

        #if LUA_ALLOWED
        loadLuaScript(path);
        #end
    }

    public inline function loadHScript(path:String)
    {
        #if HSCRIPT_ALLOWED
        if (Paths.fileExists(path + '.hx'))
        {
            try
            {
                var script:HScript = new HScript(Paths.getPath(path + '.hx'), STATE);
    
                if (script.parsingException != null)
                {
                    debugPrint('Error on Loading: ' + script.parsingException.message, FlxColor.RED);

                    script.destroy();
                } else {
                    hScripts.push(script);

                    trace('Haxe Script "' + path + '" has been successfully loaded');
                }
            } catch (error) {
                debugPrint('Error: ' + error.message, FlxColor.RED);
            }
        }
        #end
    }

    public inline function loadLuaScript(path:String)
    {
        #if LUA_ALLOWED
        if (Paths.fileExists(path + '.lua'))
        {
            var script:LuaScript = new LuaScript(Paths.getPath(path + '.lua'), STATE);

            try
            {
                luaScripts.push(script);

                trace('Lua Script "' + path + '" has been successfully loaded');
            } catch(error) {
                debugPrint('Error: ' + error, FlxColor.RED);
            }
        }
        #end
    }

    public inline function setOnScripts(name:String, value:Dynamic)
    {
        #if HSCRIPT_ALLOWED
        setOnHScripts(name, value);
        #end

        #if LUA_ALLOWED
        setOnLuaScripts(name, value);
        #end
    }

    public inline function setOnHScripts(name:String, value:Dynamic)
    {
        #if HSCRIPT_ALLOWED
        if (hScripts.length > 0)
            for (script in hScripts)
                script.set(name, value);
        #end
    }

    public inline function setOnLuaScripts(name:String, value:Dynamic)
    {
        #if LUA_ALLOWED
        if (luaScripts.length > 0)
        {
            for (script in luaScripts)
            {
                if (Reflect.isFunction(value))
                    script.setFunction(name, value);
                else
                    script.set(name, value);
            }
        }
        #end
    }

    public inline function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null)
    {
        #if HSCRIPT_ALLOWED
        callOnHScripts(callback, arguments);
        #end

        #if LUA_ALLOWED
        callOnLuaScripts(callback, arguments);
        #end
    }

    public function callOnHScripts(callback:String, arguments:Array<Dynamic> = null)
    {
        #if HSCRIPT_ALLOWED
        if (hScripts.length > 0)
        {
            try
            {
                for (script in hScripts)
                {
                    if (script == null)
                        continue;

                    script.call(callback, arguments);
                }
            } catch(_) {}
        }
        #end
    }

    public function callOnLuaScripts(callback:String, arguments:Array<Dynamic> = null)
    {
        #if LUA_ALLOWED
        if (luaScripts.length > 0)
        {
            try
            {
                for (script in luaScripts)
                {
                    if (script == null)
                        continue;

                    script.call(callback, arguments);
                }
            } catch(_) {}
        }
        #end
    }

    public inline function destroyScripts()
    {
        #if HSCRIPT_ALLOWED
        destroyHScripts();
        #end

        #if LUA_ALLOWED
        destroyLuaScripts();
        #end
    }

    public inline function destroyHScripts()
    {
        #if HSCRIPT_ALLOWED
        if (hScripts.length > 0)
        {
            for (script in hScripts)
            {
                script.destroy();

                hScripts.remove(script);
            }
        }
        #end
    }

    public inline function destroyLuaScripts()
    {
        #if LUA_ALLOWED
        if (luaScripts.length > 0)
        {
            for (script in luaScripts)
            {
                script.close();

                luaScripts.remove(script);
            }
        }
        #end
    }
}