export GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.1:7.0

include theos/makefiles/common.mk

TWEAK_NAME = thumbsupnotifications
thumbsupnotifications_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
