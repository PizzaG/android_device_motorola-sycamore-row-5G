#!/system/bin/sh
#
# For ZUI VideoMode check, add by wangwq14.
umask 022

dumpsys SurfaceFlinger --check-video-mode > /data/zuimode/sf_checkvideomode

