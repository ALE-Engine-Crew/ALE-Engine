package utils.scripting.lua;

class LuaFileSystem extends LuaPresetBase
{
    public function new(lua:LuaScript)
    {
        super(lua);
        
        set('pathExists', function(path:String)
            {
                return Paths.fileExists(path);
            }
        );

        set('getFileContent', function(path:String)
            {
                return File.getContent(Paths.getPath(path));
            }
        );

        set('createFile', function(path:String, value:String)
            {
                File.saveContent(Paths.modFolder() + '/' + path, value);
            }
        );

        set('deleteFile', function(path:String)
            {
                FileSystem.deleteFile(Paths.modFolder() + '/' + path);
            }
        );

        set('createFolder', function(path:String)
            {
                FileSystem.createDirectory(Paths.modFolder() + '/' + path);
            }
        );

        set('deleteFolder', function(path:String)
            {
                FileSystem.deleteDirectory(Paths.modFolder() + '/' + path);
            }
        );

        set('readFolder', function(path:String)
            {
                return FileSystem.readDirectory(Paths.getPath(path));
            }
        );

        set('pathIsFolder', function(path:String)
            {
                return FileSystem.isDirectory(Paths.getPath(path));      
            }
        );
    }
}