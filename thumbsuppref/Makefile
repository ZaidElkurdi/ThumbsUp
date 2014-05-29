export GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.1:7.0

include theos/makefiles/common.mk

BUNDLE_NAME = ThumbsUpPref
ThumbsUpPref_FILES = ThumbsUpPref.mm
ThumbsUpPref_INSTALL_PATH = /Library/PreferenceBundles
ThumbsUpPref_FRAMEWORKS = UIKit
ThumbsUpPref_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ThumbsUpPref.plist$(ECHO_END)
