package funkin.substates;

class CustomTransition extends CustomSubState
{
    public var instance:CustomTransition;

    public static var finishCallback:Void -> Void = null;

    public var transIn:Bool = false;
    public var transOut:Bool = false;

    override public function new(transIn:Bool)
    {
        super(CoolVars.data.transition);

        this.transIn = transIn;
        this.transOut = !transIn;
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
        
        setOnScripts('camGame', FlxG.camera);

        setOnScripts('transIn', transIn);
        setOnScripts('transOut', transOut);

        callOnScripts('onCreate');

        callOnScripts('onCreatePost');
    }

    override function close()
    {
        instance = null;
        
        if (finishCallback != null)
        {
            if (transIn)
                finishCallback();

            finishCallback = null;
        }

        super.close();
    }
}