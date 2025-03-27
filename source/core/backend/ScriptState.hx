package core.backend;

import utils.scripting.haxe.HScript;

class ScriptState extends MusicBeatState
{
    public static var instance:ScriptState;

    private var hscripts:Array<HScript> = [];

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
    }

    public inline function loadHScript(path:String)
    {
        #if HSCRIPT_ALLOWED
        if (Paths.fileExists(path + '.hx'))
        {
            var script:HScript = new HScript();
            script.doString(File.getContent(Paths.getPath(path + '.hx')));

            hscripts.push(script);

            script.set('game', FlxG.state);
    
            script.set('add', FlxG.state.add);
            script.set('insert', FlxG.state.insert);
    
            script.set('controls', controls);

            script.set('debugPrint', debugPrint);
        }
        #end
    }

    public inline function setOnScripts(name:String, value:Dynamic)
    {
        #if HSCRIPT_ALLOWED
        setOnHScripts(name, value);
        #end
    }

    public inline function setOnHScripts(name:String, value:Dynamic)
    {
        #if HSCRIPT_ALLOWED
        if (hscripts.length > 0)
            for (script in hscripts)
                script.set(name, value);
        #end
    }

    public inline function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null)
    {
        #if HSCRIPT_ALLOWED
        callOnHScripts(callback, arguments);
        #end
    }

    public function callOnHScripts(callback:String, arguments:Array<Dynamic> = null)
    {
        #if HSCRIPT_ALLOWED
        if (hscripts.length > 0)
        {
            try
            {
                for (script in hscripts)
                {
                    if (script == null)
                        continue;

                    script.call(callback, arguments);
                }
            } catch(e:Dynamic) {}
        }
        #end
    }

    public inline function destroyScripts()
    {
        #if HSCRIPT_ALLOWED
        destroyHScripts();
        #end
    }

    public inline function destroyHScripts()
    {
        #if HSCRIPT_ALLOWED
        if (hscripts.length > 0)
            for (script in hscripts)
                script.destroy();
        #end
    }
}