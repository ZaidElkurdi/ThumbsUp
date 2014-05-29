include theos/makefiles/common.mk

TWEAK_NAME = ThumbsUpSubstrate
ThumbsUpSubstrate_FILES = Tweak.xm
ThumbsUpSubstrate_LIBRARIES = substrate objcipc
ThumbsUpSubstrate_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
