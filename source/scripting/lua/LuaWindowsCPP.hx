package scripting.lua;

import cpp.*;

import core.enums.MessageBoxIcon;

class LuaWindowsCPP extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('sendNotification', function(title:String, desc:String)
            {
                fixMainWindow();
    
                WindowsCPP.sendNotification(title, desc);
            }
        );
    
        set('setWindowLayeredMode', function(numberMode:Int)
            {
                fixMainWindow();
    
                WindowsCPP.setWindowLayeredMode(numberMode);
            }
        );
    
        set('setDesktopPosition', function(?x:Int, ?y:Int)
            {
                fixMainWindow();
                
                if (x != null)
                    WindowsCPP.moveDesktopWindowsInX(x);
    
                if (y != null)
                    WindowsCPP.moveDesktopWindowsInY(y);
            }
        );
    
        set('toggleTaskbar', function(hide:Bool)
            {
                fixMainWindow();
                
                WindowsCPP.hideTaskbar(hide);
            }
        );
    
        set('obtainRAM', function():Float
            {
                fixMainWindow();
                
                return WindowsCPP.obtainRAM();
            }
        );
    
        set('windowsScreenShot', function(path:String)
            {
                fixMainWindow();
                
                WindowsCPP.windowsScreenShot(Paths.modFolder() + '/' + path);
            }
        );
    
        set('getCursorX', function():Float
            {
                fixMainWindow();
                
                return WindowsCPP.getCursorPositionX();
            }
        );
    
        set('getCursorY', function():Float
            {
                fixMainWindow();
                
                return WindowsCPP.getCursorPositionY();
            }
        );
    
        set('setWindowBorderColor', function(r:Int, g:Int, b:Int)
            {
                fixMainWindow();
                
                WindowsCPP.setWindowBorderColor(r, g, b);
            }
        );
    
        set('showMessageBox', function(title:String, message:String, icon:String)
            {
                fixMainWindow();
                
                WindowsCPP.showMessageBox(title, message,
                    switch (icon.toUpperCase().trim())
                    {
                        case 'ERROR':
                            MessageBoxIcon.ERROR;
                        case 'QUESTION':
                            MessageBoxIcon.QUESTION;
                        case 'WARNING':
                            MessageBoxIcon.WARNING;
                        default:
                            MessageBoxIcon.INFORMATION;
                    }
                );
            }
        );
    
        set('clearTerminal', function()
            {
                fixMainWindow();
                
                WindowsTerminalCPP.clearTerminal();
            }
        );
    
        set('showConsole', function()
            {
                fixMainWindow();
                
                WindowsTerminalCPP.allocConsole();
            }
        );
    
        set('setConsoleTitle', function(title:String)
            {
                fixMainWindow();
                
                WindowsTerminalCPP.setConsoleTitle(title);
            }
        );
    
        set('disableCloseConsole', function()
            {
                fixMainWindow();
                
                WindowsTerminalCPP.disableCloseConsoleWindow();
            }
        );
    
        set('hideConsole', function()
            {
                fixMainWindow();
    
                WindowsTerminalCPP.hideConsoleWindow();
            }
        );
    }
    
    function fixMainWindow()
    {
        WindowsCPP.reDefineMainWindowTitle(lime.app.Application.current.window.title);
    }
}