package utils;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

import openfl.display.BitmapData;

import sys.FileSystem;
import sys.io.File;

import core.backend.Mods;

enum PathFolder
{
    ASSETS;
    MODS;
    BOTH;
}

/**
 * Serves to assist with file loading
 */
class Paths
{
    /**
     * Used to load a PNG image
     * @param file File Name
     * @return FlxGraphic
     */
    public static inline function image(file:String):FlxGraphic
    {
        var path = 'images/' + file + '.png';

        if (!fileExists(path))
        {
            trace('Missing Image: ' + path);
            return null;
        }

        var key = 'image:' + path;

        var cached = FlxG.bitmap.get(key);

        if (cached != null)
            return cached;

        return FlxG.bitmap.add(getPath(path), false, key);
    }

    /**
     * Used to load an .XML File
     * @param file File Name
     * @return String
     */
    public static function xml(file:String):String
    {
        var path = 'images/' + file + '.xml';

        if (!fileExists(path))
        {
            trace('Missing XML: ' + path);
            return null;
        }

        return File.getContent(getPath(path));
    }

    /**
     * Used to load image animations from XML
     * @param file File Name
     * @return FlxAtlasFrames
     */
    public static function getSparrowAtlas(file:String):FlxAtlasFrames
    {
        var graphic = image(file);
        var xmlContent = xml(file);

        if (graphic == null || xmlContent == null)
            return null;

        return FlxAtlasFrames.fromSparrow(graphic, xmlContent);
    }

    /**
     * Used to get the Path of a Font
     * @param file File Name
     * @return String
     */
    public static function font(file:String):String
    {
        var path = 'fonts/' + file;

        if (!fileExists(path))
        {
            trace('Missing Font: ' + path);
            return null;
        }

        return getPath(path);
    }

    /**
     * Used to load a sound located in the "music" folder
     * @param file 
     * @return FlxSound
     */
    public static function music(file:String):FlxSound
    {
        var path = 'music/' + file + '.ogg';

        if (!fileExists(path))
        {
            trace('Missing Music: ' + path);
            return null;
        }

        return FlxG.sound.load(getPath(path));
    }

    /**
     * Used to a sound located in the "sounds" folder
     * @param file 
     * @return FlxSound
     */
    public static function sound(file:String):FlxSound
    {
        var path = 'sounds/' + file + '.ogg';

        if (!fileExists(path))
        {
            trace('Missing Sound: ' + path);
            return null;
        }

        return FlxG.sound.load(getPath(path));
    }

    /**
     * Used to load the Instrumental of a song
     * @param song Song Name
     * @return FlxSound
     */
    public static function inst(song:String):FlxSound
    {
        song = CoolUtil.formatSongPath(song);

        if (fileExists('songs', ASSETS))
            for (folder in FileSystem.readDirectory('assets/songs'))
                if (song == CoolUtil.formatSongPath(folder) && fileExists('songs/' + folder + '/Inst.ogg', ASSETS))
                    return FlxG.sound.load('assets/songs/' + folder + '/song/Inst.ogg');
        
        trace('Missing File: ' + 'songs/' + song + '/song/Inst.ogg');

        return null;
    }

    /**
     * Used to the Vocals of a song
     * @param song Song Name
     * @return FlxSound
     */
    public static function voices(song:String):FlxSound
    {
        song = CoolUtil.formatSongPath(song);

        if (fileExists('songs', ASSETS))
            for (folder in FileSystem.readDirectory('assets/songs'))
                if (song == CoolUtil.formatSongPath(folder) && fileExists('songs/' + folder + '/song/Voices.ogg', ASSETS))
                    return FlxG.sound.load('assets/songs/' + folder + '/song/Voices.ogg');

        trace('Missing File: ' + 'songs/' + song + '/song/Voices.ogg');

        return null;
    }

    /**
     * Defines where the files should be searched
     * @param file File Path
     * @return String
     */
    public static inline function getPath(file:String):String
    {
        #if MODS_ALLOWED
        if (fileExists(file, MODS))
            return modFolder() + '/' + file;
        #end

        if (fileExists(file, ASSETS))
            return 'assets/' + file;

        trace('Missing File: ' + file);

        return null;
    }

    /**
     * Determines whether or not a file exists
     * @param path File Path
     * @param pathMode ASSETS | MODS | BOTH
     * @return Bool
     */
    public static inline function fileExists(path:String, ?pathMode:PathFolder = BOTH):Bool
    {
        #if MODS_ALLOWED
        if (FileSystem.exists(modFolder() + '/' + path) && (pathMode == MODS || pathMode == BOTH))
            return true;
        #end

        if (FileSystem.exists('assets/' + path) && (pathMode == ASSETS || pathMode == BOTH))
            return true;
        
        return false;
    }

    public static inline function modFolder():String
        return 'mods/' + Mods.folder;
}