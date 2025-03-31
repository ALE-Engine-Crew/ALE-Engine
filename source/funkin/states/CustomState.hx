package funkin.states;

import scripting.haxe.HScript;

class CustomState extends ScriptState
{
    public static var instance:ScriptState;

    public var scriptName:String = '';

    var haxeScripts:Array<HScript> = [];

    override public function new(script:String)
    {
        super();

        scriptName = script;
    }

    override public function create()
    {        
        super.create();

        instance = this;

        loadScript('scripts/states/' + scriptName);
        loadScript('scripts/states/global');

        setOnScripts('resetCustomState', resetCustomState);
        
        setOnScripts('camGame', camGame);
        setOnScripts('camHUD', camHUD);
        setOnScripts('camOther', camOther);

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
        callOnScripts('onStepHit');
        setOnScripts('curStep', curStep);

        super.stepHit();
    }

    override public function beatHit()
    {
        callOnScripts('onBeatHit');
        setOnScripts('curBeat', curBeat);

        super.beatHit();
    }

    override public function sectionHit()
    {
        callOnScripts('onSectionHit');
        setOnScripts('curSection', curSection);

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

    public function resetCustomState()
        MusicBeatState.switchState(new CustomState(scriptName));
}