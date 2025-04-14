package funkin.debug;

import openfl.system.Capabilities;

class SystemField extends DebugField
{
    override public function new()
    {
        super('System Info');
    }

    var theText:String = '';

    override function updateField()
    {
        theText = 'Operating System: ' + Capabilities.os;
        theText += '\nScreen Resolution: ' + Capabilities.screenResolutionX + ' x ' + Capabilities.screenResolutionY;
        theText += '\nCPU Architecture: ' + Capabilities.cpuArchitecture;
        theText += '\nLanguage: ' + Capabilities.language;

        text.text = theText;
    }
}