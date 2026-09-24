#ifndef IOS_VIDEO_H
#define IOS_VIDEO_H

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

@interface IOSVideoPlayer : NSObject

+ (void)playVideo:(NSString *)videoPath;
+ (void)stopVideo;
+ (BOOL)hasFinished;

@end

#ifdef __cplusplus
extern "C" {
#endif

void ios_play_video(const char *path);
void ios_stop_video(void);
bool ios_video_has_finished(void);

#ifdef __cplusplus
}
#endif

#endif
