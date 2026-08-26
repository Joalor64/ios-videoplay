#ifndef IOS_VIDEO_H
#define IOS_VIDEO_H

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

@interface IOSVideoPlayer : NSObject

+ (void)playVideo:(NSString *)videoPath;
+ (void)stopVideo;

@end

#endif
