package iosvideo;

@:cppFileCode('
extern "C" {
    void ios_play_video(const char* path);
    void ios_stop_video(void);
    bool ios_video_has_finished(void);
}
')
class IOSVideo
{
	#if ios
	static var pollTimer:haxe.Timer;
	#end

	public static var onComplete:Void->Void = null;

	public static function play(path:String):Void
	{
		#if ios
		stopPolling();
		untyped __cpp__("ios_play_video({0}.utf8_str())", path);
		startPolling();
		#else
		trace("Video playback only implemented for iOS target.");
		#end
	}

	public static function stop():Void
	{
		#if ios
		stopPolling();
		untyped __cpp__("ios_stop_video()");
		#end
	}

	#if ios
	static function startPolling():Void
	{
		pollTimer = new haxe.Timer(100);
		pollTimer.run = function()
		{
			if (untyped __cpp__("ios_video_has_finished()"))
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
