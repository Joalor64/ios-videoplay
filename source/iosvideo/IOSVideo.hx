package iosvideo;

#if ios
import cpp.ConstCharStar;

@:buildXml('<target id="haxe"><compilerflag value="-I${haxelib:ios-videoplay}/native"/></target>')
@:include("IOSVideo.h")
extern class IOSVideoNative
{
	@:native("ios_play_video")
	static function play(path:ConstCharStar):Void;

	@:native("ios_stop_video")
	static function stop():Void;

	@:native("ios_video_has_finished")
	static function hasFinished():Bool;
}
#end

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
		IOSVideoNative.play(path);
		startPolling();
		#else
		trace("Video playback only implemented for iOS target.");
		#end
	}

	public static function stop():Void
	{
		#if ios
		stopPolling();
		IOSVideoNative.stop();
		#end
	}

	#if ios
	static function startPolling():Void
	{
		pollTimer = new haxe.Timer(100);
		pollTimer.run = function()
		{
			if (IOSVideoNative.hasFinished())
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
