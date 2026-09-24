#ifndef IOS_VIDEO_H
#define IOS_VIDEO_H

#include <stdbool.h>

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