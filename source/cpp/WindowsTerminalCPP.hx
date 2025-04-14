package cpp;

#if (cpp && windows)
@:cppFileCode('
#include <Windows.h>
#include <windowsx.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <winternl.h>
#include <Shlobj.h>
#include <commctrl.h>
#include <string>

#define UNICODE

#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "ntdll.lib")
#pragma comment(lib, "User32.lib")
#pragma comment(lib, "Shell32.lib")
#pragma comment(lib, "gdi32.lib")
')
#end

class WindowsTerminalCPP
{
    #if (cpp && windows)
	@:functionCode('
        system("CLS");
        std::cout<< "" <<std::flush;
    ')
    #end
	public static function clearTerminal() {}

    #if (cpp && windows)
	@:functionCode('
        if (!AllocConsole())
            return;

        freopen("CONIN$", "r", stdin);
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);

        HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE);
        SetConsoleMode(output, ENABLE_PROCESSED_OUTPUT | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
    ')
    #end
	public static function allocConsole() 
    {
        if (CoolVars.isConsoleVisible)
            return;

        CoolVars.isConsoleVisible = true;
    }

    #if (cpp && windows)
	@:functionCode('
        SetConsoleTitleA(text);
    ')
    #end
	public static function setConsoleTitle(text:String) {}

    #if (cpp && windows)
	@:functionCode('
        HWND hwnd = GetConsoleWindow();
        HMENU hmenu = GetSystemMenu(hwnd, FALSE);
        EnableMenuItem(hmenu, SC_CLOSE, MF_GRAYED);
    ')
    #end
	public static function disableCloseConsoleWindow() {}

    #if (cpp && windows)
	@:functionCode('
        HWND hChild = GetConsoleWindow();
        ShowWindow(hChild, SW_HIDE);
    ')
    #end
	public static function hideConsoleWindow()
    {
        if (!CoolVars.isConsoleVisible)
            return;

        CoolVars.isConsoleVisible = false;
    }
}