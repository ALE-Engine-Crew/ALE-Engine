package core.enums;

@:enum abstract MessageBoxIcon(Int)
{
	var ERROR = 0x00000010;
	var QUESTION = 0x00000020;
	var WARNING = 0x00000030;
	var INFORMATION = 0x00000040;
}