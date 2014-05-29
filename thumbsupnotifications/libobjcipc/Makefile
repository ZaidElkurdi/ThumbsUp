export THEOS_DEVICE_IP=128.54.249.78

export TARGET = :clang
export ARCHS = armv7 arm64
export ADDITIONAL_OBJCFLAGS = -fvisibility=default -fvisibility-inlines-hidden -fno-objc-arc -O2

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/library.mk
LIBRARY_NAME = libobjcipc
libobjcipc_FILES = IPC.m Connection.m Message.m
libobjcipc_FRAMEWORKS = CoreFoundation Foundation UIKit
libobjcipc_INSTALL_PATH = /usr/lib/
libobjcipc_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/aggregate.mk
SUBPROJECTS = substrate


after-install::
	install.exec "killall -9 backboardd"