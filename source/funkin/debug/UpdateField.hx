package funkin.debug;

class UpdateField extends DebugField
{
    public function new()
    {
        super('Outdated!', null, 'Local\nOnline\nUpdate');
    }

    public var updateTimer:Float = 0;

    override function updateField(elapsed:Float)
    {
        if (enabled)
        {
            if (updateTimer < 5)
                updateTimer += elapsed / 100;
            else
                enabled = false;
        }
    }
}