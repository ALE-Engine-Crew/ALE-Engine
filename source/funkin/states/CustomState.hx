package funkin.states;

class CustomState extends ScriptState
{
    public static var instance:CustomState;

    public var scriptName:String = '';

    override public function new(script:String)
    {
        super();

        scriptName = script;
    }

    override public function create()
    {        
        super.create();

        instance = this;

        loadScripts();
    }

    public function loadScripts()
    {
        loadScript('scripts/states/' + scriptName);
        loadScript('scripts/states/global');

        setOnScripts('resetCustomState', resetCustomState);
        
        setOnScripts('camGame', camGame);
        setOnScripts('camHUD', camHUD);

        callOnScripts('onCreate');

        callOnScripts('onCreatePost');
    }

    override public function update(elapsed:Float)
    {
        callOnScripts('onUpdate', [elapsed]);

        super.update(elapsed);

        callOnScripts('onUpdatePost', [elapsed]);
    }

    override public function destroy()
    {
        callOnScripts('onDestroy');

        destroyScripts();

        instance = null;

        super.destroy();
    }

    override public function stepHit(curStep:Int)
    {
        super.stepHit(curStep);

        callOnScripts('onStepHit', [curStep]);
    }

    override public function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        callOnScripts('onBeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        callOnScripts('onSectionHit', [curSection]);
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onFocus');
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        super.openSubState(substate);

        callOnScripts('onOpenSubState', [substate]);
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        callOnScripts('onCloseSubState');
    }

    public function resetCustomState()
    {
        shouldClearMemory = false;

        CoolUtil.switchState(new CustomState(scriptName), true, true);
    }
}