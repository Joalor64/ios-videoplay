#import "IOSVideo.h"
#import <UIKit/UIKit.h>

@implementation IOSVideoPlayer

static AVPlayerViewController *videoController = nil;

+ (void)playVideo:(NSString *)videoPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (!rootVC) return;

        NSURL *url;
        if ([videoPath hasPrefix:@"http"]) {
            url = [NSURL URLWithString:videoPath];
        } else {
            url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:videoPath ofType:nil]];
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

@end

extern "C" {
    void ios_play_video(const char* path) {
        [IOSVideoPlayer playVideo:[NSString stringWithUTF8String:path]];
    }
    void ios_stop_video() {
        [IOSVideoPlayer stopVideo];
    }
}
