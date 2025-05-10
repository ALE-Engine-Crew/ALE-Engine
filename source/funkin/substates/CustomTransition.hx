package funkin.substates;

class CustomTransition extends CustomSubState
{
    public var instance:CustomTransition;

    public final finishCallback:Void -> Void;

    public var transIn:Bool = false;
    public var transOut:Bool = false;

    override public function new(transIn:Bool, ?finishCallback:Void -> Void = null)
    {
        super(CoolVars.data.transition);

        this.transIn = transIn;
        this.transOut = !transIn;

        this.finishCallback = finishCallback;
    }

    override function create()
    {
        super.create();

        instance = this;
    }

    override function loadScripts()
    {
        loadScript('scripts/substates/' + scriptName);
        loadScript('scripts/substates/global');
        
        setOnHScripts('camGame', FlxG.camera);

        setOnScripts('transIn', transIn);
        setOnScripts('transOut', transOut);

        setOnScripts('finishCallback', finishCallback);
    }

    override function close()
    {
        instance = null;

        super.close();
    }
}