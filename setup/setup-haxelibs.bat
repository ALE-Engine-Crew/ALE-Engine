@echo off
cd ..
@echo on
echo Installing dependencies

@if not exist ".haxelib\" mkdir .haxelib

haxelib install flixel-addons 3.2.3
haxelib install flixel-ui 2.6.1
haxelib install flixel-tools 1.5.1
haxelib install away3d 5.0.9

haxelib git flixel https://github.com/MobilePorting/flixel 5.6.1
haxelib git hxcpp https://github.com/mcagabe19-stuff/hxcpp
haxelib git openfl https://github.com/MobilePorting/openfl 9.3.3

haxelib install setup/sscript.zip
haxelib install lime
haxelib install tjson

echo Finished!
pause