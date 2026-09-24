package iosvideo;

#if ios
@:cppFileCode('
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

@interface IOSVideoPlayer : NSObject
+ (void)playVideo:(NSString *)videoPath;
+ (void)stopVideo;
+ (BOOL)hasFinished;
+ (void)playerItemDidReachEnd:(NSNotification *)notification;
@end

static AVPlayerViewController *g_playerViewController = nil;
static BOOL g_videoFinished = NO;

@implementation IOSVideoPlayer

+ (void)playVideo:(NSString *)videoPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:nil];

        if (g_playerViewController != nil) {
            [g_playerViewController.player pause];
            [g_playerViewController dismissViewControllerAnimated:NO completion:nil];
            g_playerViewController = nil;
        }

        if (videoPath == nil || videoPath.length == 0) {
            NSLog(@"IOSVideo: no video path given");
            g_videoFinished = YES;
            return;
        }

        NSURL *url = [NSURL fileURLWithPath:videoPath];

        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC == nil) {
            NSLog(@"IOSVideo: no root view controller to present on");
            g_videoFinished = YES;
            return;
        }

        AVPlayer *player = [AVPlayer playerWithURL:url];
        g_playerViewController = [[AVPlayerViewController alloc] init];
        g_playerViewController.player = player;
        g_playerViewController.showsPlaybackControls = YES;

        g_videoFinished = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:player.currentItem];

        [rootVC presentViewController:g_playerViewController animated:YES completion:^{
            [player play];
        }];
    });
}

+ (void)playerItemDidReachEnd:(NSNotification *)notification {
    g_videoFinished = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
}

+ (void)stopVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:nil];
        if (g_playerViewController) {
            [g_playerViewController.player pause];
            [g_playerViewController dismissViewControllerAnimated:YES completion:nil];
            g_playerViewController = nil;
        }
        g_videoFinished = YES;
    });
}

+ (BOOL)hasFinished {
    return g_videoFinished;
}

@end

extern "C" {
    void ios_play_video(const char* path) {
        [IOSVideoPlayer playVideo:[NSString stringWithUTF8String:path]];
    }
    void ios_stop_video() {
        [IOSVideoPlayer stopVideo];
    }
    bool ios_video_has_finished() {
        return [IOSVideoPlayer hasFinished];
    }
}
')
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

		var resolvedPath:String = resolvePath(path);
		if (resolvedPath == null)
		{
			trace('IOSVideo: could not resolve a playable path for "$path"');
			return;
		}

		untyped __cpp__("ios_play_video({0}.utf8_str())", resolvedPath);
		startPolling();
		#else
		trace("Video playback only implemented for iOS target.");
		#end
	}

	#if ios
	static function resolvePath(path:String):String
	{
		if (path == null)
			return null;

		if (StringTools.startsWith(path, "http"))
			return path;

		var destination = haxe.io.Path.join([lime.system.System.applicationStorageDirectory, haxe.io.Path.withoutDirectory(path)]);

		if (!sys.FileSystem.exists(destination))
		{
			var bytes = lime.utils.Assets.getBytes(path);
			if (bytes == null)
			{
				trace('IOSVideo: no asset found for "$path"');
				return null;
			}

			sys.io.File.saveBytes(destination, bytes);
		}

		return destination;
	}
	#end

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
