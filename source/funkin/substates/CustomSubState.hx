package funkin.substates;

class CustomSubState extends ScriptSubState
{
    public static var instance:CustomSubState;

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
        loadScript('scripts/substates/' + scriptName);
        loadScript('scripts/substates/global');
        
        setOnScripts('camGame', FlxG.camera);

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

    override public function stepHit()
    {
        setOnScripts('curStep', curStep);
        callOnScripts('onStepHit');

        super.stepHit();
    }

    override public function beatHit()
    {
        setOnScripts('curBeat', curBeat);
        callOnScripts('onBeatHit');

        super.beatHit();
    }

    override public function sectionHit()
    {
        setOnScripts('curSection', curSection);
        callOnScripts('onSectionHit');

        super.sectionHit();
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
}