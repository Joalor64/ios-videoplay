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
@end

static AVPlayerViewController *g_playerViewController = nil;
static BOOL g_videoFinished = NO;

@implementation IOSVideoPlayer

+ (void)playVideo:(NSString *)videoPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        if (!url) return;

        AVPlayer *player = [AVPlayer playerWithURL:url];
        g_playerViewController = [[AVPlayerViewController alloc] init];
        g_playerViewController.player = player;
        g_playerViewController.showsPlaybackControls = YES;

        g_videoFinished = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:player.currentItem];

        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
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
