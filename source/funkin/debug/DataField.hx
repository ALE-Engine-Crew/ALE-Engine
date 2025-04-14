package funkin.debug;

class DataField extends DebugField
{
    override public function new()
    {
        super('Game Data');
    }

    var theText:String = '';

    override function updateField()
    {
        theText = 'Developer Mode: ' + CoolVars.data.developerMode;
        theText += '\nInitial State: ' + CoolVars.data.initialState;
        theText += '\nFreeplay State: ' + CoolVars.data.freeplayState;
        theText += '\nStory Menu State: ' + CoolVars.data.storyMenuState;
        theText += '\nMaster Editor Menu: ' + CoolVars.data.masterEditorMenu;
        theText += '\nOptions State: ' + CoolVars.data.optionsState;
        theText += '\nPause SubState: ' + CoolVars.data.pauseSubState;
        theText += '\nGame Over Screen: ' + CoolVars.data.gameOverScreen;
        theText += '\nTransition: ' + CoolVars.data.transition;
        theText += '\nTitle: ' + CoolVars.data.title;
        theText += '\nIcon: ' + CoolVars.data.icon;
        theText += '\nBPM: ' + CoolVars.data.bpm;
        theText += '\nDiscord ID: ' + CoolVars.data.discordID;

        text.text = theText;
    }
}