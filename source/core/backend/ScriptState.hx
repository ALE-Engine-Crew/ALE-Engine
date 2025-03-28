package core.backend;

import utils.scripting.haxe.HScript;

import utils.scripting.lua.LuaScript;

class ScriptState extends MusicBeatState
{
    public static var instance:ScriptState;

    public var hScripts:Array<HScript> = [];

    public var luaScripts:Array<LuaScript> = [];

    override public function create()
    {
        instance = this;

        super.create();
    }

    override public function destroy()
    {
        instance = null;

        super.destroy();
    }

    public inline function loadScript(path:String)
    {
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
                var script:HScript = new HScript(Paths.getPath(path + '.hx'));
    
                if (script.parsingException != null)
                {
                    debugPrint('Error on Loading: ' + script.parsingException.message, FlxColor.RED);

                    script.destroy();
                } else {
                    hScripts.push(script);
        
                    script.set('game', FlxG.state);
            
                    script.set('add', FlxG.state.add);
                    script.set('insert', FlxG.state.insert);
            
                    script.set('controls', controls);
        
                    script.set('debugPrint', function(oso:String)
                    {
                        debugPrint(oso);
                    }
                    );
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
            var script:LuaScript = new LuaScript(Paths.getPath(path + '.lua'));

            try
            {
                luaScripts.push(script);

                script.setFunction('add', FlxG.state.add);
                script.setFunction('insert', FlxG.state.insert);
        
                script.set('FlxSprite', FlxSprite);
    
                script.setFunction('debugPrint', function(text:String, ?color:String)
                    {
                        debugPrint(text, color == null ? null : CoolUtil.colorFromString(color));
                    }
                );

                script.setFunction('getProperty', function(name:String) { return Reflect.getProperty(game.states.PlayState.instance, name); });
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