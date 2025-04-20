@echo off
cd ..
@echo on
echo Installing dependencies

@if not exist ".haxelib\" mkdir .haxelib

haxelib git flixel https://github.com/MobilePorting/flixel 5.6.1
haxelib git hxcpp https://github.com/MobilePorting/hxcpp --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 633fcc051399afed6781dd60cbf30ed8c3fe2c5a --skip-dependencies

haxelib install openfl 9.4.1
haxelib install tjson 1.4.0
haxelib install lime 8.2.2
haxelib install flixel-addons 3.2.3
haxelib install extension-androidtools 2.1.1 --skip-dependencies
haxelib install haxeui-core --skip-dependencies
haxelib install haxeui-flixel --skip-dependencies
haxelib install ale-ui --skip-dependencies

haxelib install setup/sscript.zip