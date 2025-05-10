package funkin.substates;

class CustomSubState extends ScriptSubState
{
    public static var instance:CustomSubState;

    public var scriptName:String = '';

    public var arguments:Array<Dynamic>;

    override public function new(script:String, ?arguments:Array<Dynamic>)
    {
        super();

        scriptName = script;

        this.arguments = arguments;
    }

    override public function create()
    {        
        super.create();

        instance = this;

        loadScripts();

        callOnScripts('onCreate');

        setOnScripts('arguments', arguments);

        openCallback = function() { callOnScripts('onOpen'); };
        closeCallback = function() { callOnScripts('onClose'); };

        setOnHScripts('camGame', FlxG.camera);

        callOnScripts('postCreate');
    }

    private function loadScripts()
    {
        loadScript('scripts/substates/' + scriptName);
        loadScript('scripts/substates/global');
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
}