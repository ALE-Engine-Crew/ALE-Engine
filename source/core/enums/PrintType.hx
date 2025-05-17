package core.enums;

enum abstract PrintType(String)
{
    var ERROR = 'error';
    var WARNING = 'warning';
    var TRACE = 'trace';
    var HSCRIPT = 'hscript';
    var LUA = 'lua';
    var MISSING_FILE = 'missing_file';
    var CUSTOM = 'custom';
    var POP_UP = 'pop-up';

    private static var dataMap:Map<PrintType, Array<Dynamic>> = [
        ERROR => ['ERROR', 0xFFFF5555],
        WARNING => ['WARNING', 0xFFFFA500],
        TRACE => ['TRACE', 0xFFFFFFFF],
        HSCRIPT => ['HSCRIPT', 0xFF88CC44],
        LUA => ['LUA', 0xFF4466DD],
        MISSING_FILE => ['MISSING FILE', 0xFFFF7F00],
        POP_UP => ['POP-UP', 0xFFFF00FF]
    ];

    public static function typeToString(type:PrintType):String
        return dataMap.get(type)[0];

    public static function typeToColor(type:PrintType):FlxColor
        return dataMap.get(type)[1];
}