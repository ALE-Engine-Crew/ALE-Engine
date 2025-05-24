package funkin.states;

import haxe.ds.StringMap;

class CustomState extends ScriptState
{
    public static var instance:CustomState;

    public var scriptName:String = '';

    public var arguments:Array<Dynamic>;
    
    public var hsVariables:StringMap<Dynamic>;
    public var luaVariables:StringMap<Dynamic>;

    override public function new(script:String, ?arguments:Array<Dynamic>, ?hsVariables:StringMap<Dynamic>, ?luaVariables:StringMap<Dynamic>)
    {
        super();

        scriptName = script;

        this.arguments = arguments;

        this.hsVariables = hsVariables;
        this.luaVariables = luaVariables;
    }

    override public function create()
    {        
        super.create();

        instance = this;

        loadScripts();

        setOnScripts('arguments', arguments);

        for (map in [hsVariables, luaVariables])
            if (map != null)
                for (key in map.keys())
                    if (map == hsVariables)
                        setOnHScripts(key, map.get(key));
                    else
                        setOnLuaScripts(key, map.get(key));

        setOnScripts('resetCustomState', resetCustomState);
        
        callOnScripts('onCreate');

        callOnScripts('postCreate');
    }

    public function loadScripts()
    {
        loadScript('scripts/states/' + scriptName);
        loadScript('scripts/states/global');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        callOnScripts('postUpdate', [elapsed]);
    }

    override public function destroy()
    {
        super.destroy();

        callOnScripts('onDestroy');

        instance = null;

        callOnScripts('postDestroy');

        destroyScripts();
    }

    override public function stepHit(curStep:Int)
    {
        super.stepHit(curStep);

        callOnScripts('onStepHit', [curStep]);

        callOnScripts('postStepHit', [curStep]);
    }

    override public function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        callOnScripts('onBeatHit', [curBeat]);

        callOnScripts('postBeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        callOnScripts('onSectionHit', [curSection]);

        callOnScripts('postSectionHit', [curSection]);
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onOnFocus');

        callOnScripts('postOnFocus');
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onOnFocusLost');

        callOnScripts('postOnFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        super.openSubState(substate);

        callOnHScripts('onOpenSubState', [substate]);
        callOnLuaScripts('onOpenSubState', [Type.getClassName(Type.getClass(substate))]);

        callOnHScripts('postOpenSubState', [substate]);
        callOnLuaScripts('postOpenSubState', [Type.getClassName(Type.getClass(substate))]);
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        callOnScripts('onCloseSubState');

        callOnScripts('postCloseSubState');
    }

    public function resetCustomState()
    {
        shouldClearMemory = false;

        CoolUtil.switchState(() -> new CustomState(scriptName), true, true);
    }
}