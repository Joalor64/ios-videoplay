package iosvideo;

#if ios
import cpp.Lib;
#end

class IOSVideo
{
    #if ios
    static var ios_play_video = Lib.load("haxeApp", "ios_play_video", 1);
    static var ios_stop_video = Lib.load("haxeApp", "ios_stop_video", 0);
    static var ios_video_has_finished = Lib.load("haxeApp", "ios_video_has_finished", 0);

    static var pollTimer:haxe.Timer;
    #end

    public static var onComplete:Void->Void = null;

    public static function play(path:String):Void
    {
        #if ios
        stopPolling();
        ios_play_video(path);
        startPolling();
        #else
        trace("Video playback only implemented for iOS target.");
        #end
    }

    public static function stop():Void
    {
        #if ios
        stopPolling();
        ios_stop_video();
        #end
    }

    #if ios
    static function startPolling():Void
    {
        pollTimer = new haxe.Timer(100);
        pollTimer.run = function()
        {
            if (ios_video_has_finished())
            {
                stopPolling();

                if (onComplete != null)
                    onComplete();
            }
        };
    }

    static function stopPolling():Void
    {
        if (pollTimer != null)
        {
            pollTimer.stop();
            pollTimer = null;
        }
    }
    #end
}
