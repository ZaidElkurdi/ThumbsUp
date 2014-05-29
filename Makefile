export GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.1:7.0
export THEOS_DEVICE_IP=128.54.249.78

include theos/makefiles/common.mk
export GO_EASY_ON_ME=1

TWEAK_NAME=ThumbsUp2
ThumbsUp2_FILES=Tweak.xm BookmarkView.m UIImage+ImageEffects.m
ThumbsUp2_FRAMEWORKS=Foundation UIKit CoreGraphics Accelerate MediaPlayer
ThumbsUp2_PRIVATE_FRAMEWORKS= AppSupport
ThumbsUp2_LIBRARIES=substrate objcipc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += thumbsuppref
SUBPROJECTS += thumbsupsubstrate
include $(THEOS_MAKE_PATH)/aggregate.mk


BUNDLE_NAME = ThumbsUpResources
ThumbsUpResources_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
include $(THEOS)/makefiles/bundle.mk

after-install::
	@install.exec "killall -9 SpringBoard"
