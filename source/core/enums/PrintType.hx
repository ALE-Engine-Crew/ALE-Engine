package core.enums;

enum abstract PrintType(String)
{
    var ERROR = 'error';
    var WARNING = 'warning';
    var TRACE = 'trace';
    var HSCRIPT = 'hscript';
    var LUA = 'lua';
}