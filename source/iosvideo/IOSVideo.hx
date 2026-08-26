package iosvideo;

#if ios
import cpp.Lib;
#end

class IOSVideo
{
    #if ios
    static var ios_play_video = Lib.load("haxeApp", "ios_play_video", 1);
    static var ios_stop_video = Lib.load("haxeApp", "ios_stop_video", 0);
    #end

    public static function play(path:String):Void
    {
        #if ios
        ios_play_video(path);
        #else
        trace("Video playback only implemented for iOS target.");
        #end
    }

    public static function stop():Void
    {
        #if ios
        ios_stop_video();
        #end
    }
}
