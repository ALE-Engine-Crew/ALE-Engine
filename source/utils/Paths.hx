package utils;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;

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
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var localTrackedAssets:Array<String> = [];

    /**
     * Used to load a PNG image
     * @param file File Name
     * @return FlxGraphic
     */
    public static function image(file:String):FlxGraphic
    {
        var path = 'images/' + file + '.png';

        var bitmap:BitmapData = null;

        if (currentTrackedAssets.exists(path))
        {
            localTrackedAssets.push(path);

            return currentTrackedAssets.get(path);
        } else if (fileExists(path)) {
            bitmap = BitmapData.fromFile(getPath(path));
        }

        if (bitmap != null)
        {
            var returnValue = cacheBitmap(path, bitmap);

            if (returnValue != null)
                return returnValue;
        }

        trace('Missing File: ' + path);

        return null;
    }
    
	/**
	 * Used to Cache Bitmaps
     * (Taken from Psych Engine)
	 * @param file File Name
	 * @param bitmap Bitmap Data
	 */
	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null)
	{
		if (bitmap == null)
		{
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
            
			if (bitmap == null)
                return null;
		}

		if (ClientPrefs.data.cacheOnGPU)
		{
			var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);

			bitmap.image.data = null;
			bitmap.dispose();
			bitmap.disposeImage();
			bitmap = BitmapData.fromTexture(texture);
		}

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
        
		currentTrackedAssets.set(file, newGraphic);

		return newGraphic;
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
    public static function inst():FlxSound
    {
        if (fileExists(PlayState.songRoute + '/song/Inst.ogg'))
            return FlxG.sound.load(getPath(PlayState.songRoute + '/song/Inst.ogg'));
        
        trace('Missing File: ' + PlayState.songRoute + '/song/Inst.ogg');

        return null;
    }

    /**
     * Used to the Vocals of a song
     * @param song Song Name
     * @return FlxSound
     */
    public static function voices():FlxSound
    {
        if (fileExists(PlayState.songRoute + '/song/Voices.ogg'))
            return FlxG.sound.load(getPath(PlayState.songRoute + '/song/Voices.ogg'));

        trace('Missing File: ' + PlayState.songRoute + '/song/Voices.ogg');

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
    
    public static function clearEngineCache()
    {
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);

			if (obj != null && !currentTrackedAssets.exists(key))
			{
				FlxG.bitmap._cache.remove(key);

				obj.destroy();
			}
		}

        for (key in currentTrackedAssets.keys())
            currentTrackedAssets.remove(key);
    }
}