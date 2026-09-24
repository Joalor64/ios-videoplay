#import "../source/iosvideo/IOSVideo.h"
#import <UIKit/UIKit.h>

@implementation IOSVideoPlayer

static AVPlayerViewController *videoController = nil;
static BOOL videoFinished = NO;

+ (UIViewController *)rootViewController {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) return window.rootViewController;
            }
        }
    }
    return nil;
}

+ (void)playVideo:(NSString *)videoPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [self rootViewController];
        if (!rootVC) return;

        if (videoController != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [videoController.player pause];
            [videoController dismissViewControllerAnimated:NO completion:nil];
            videoController = nil;
        }

        videoFinished = NO;

        NSURL *url;
        if ([videoPath hasPrefix:@"http"]) {
            url = [NSURL URLWithString:videoPath];
        } else {
            NSString *directory = [videoPath stringByDeletingLastPathComponent];
            NSString *fileName = [[videoPath lastPathComponent] stringByDeletingPathExtension];
            NSString *extension = [videoPath pathExtension];

            NSString *resolvedPath = [[NSBundle mainBundle] pathForResource:fileName
                                                                       ofType:extension
                                                                  inDirectory:directory];

            if (resolvedPath == nil) {
                resolvedPath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
            }

            if (resolvedPath == nil) {
                NSLog(@"[IOSVideo] Could not locate video resource '%@' (looked in directory '%@'). Skipping playback to avoid a crash.", videoPath, directory);
                return;
            }

            url = [NSURL fileURLWithPath:resolvedPath];
        }

        AVPlayer *player = [AVPlayer playerWithURL:url];
        videoController = [[AVPlayerViewController alloc] init];
        videoController.player = player;
        videoController.showsPlaybackControls = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:player.currentItem];

        [rootVC presentViewController:videoController animated:YES completion:^{
            [player play];
        }];
    });
}

+ (void)videoDidFinish:(NSNotification *)notification {
    videoFinished = YES;
    [self stopVideo];
}

+ (void)stopVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (videoController != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [videoController.player pause];
            [videoController dismissViewControllerAnimated:YES completion:^{
                videoController = nil;
            }];
        }
    });
}

+ (BOOL)hasFinished {
    return videoFinished;
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
