TARGET = iphone:11.2:10.0
FINALPACKAGE=1
DEBUG=0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ShowTouch
ShowTouch_FILES = Tweak.xm
ShowTouch_LIBRARIES = colorpicker
ShowTouch_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-ShowTouch-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/ShowTouch
	cp -r Resources/ $(THEOS_STAGING_DIR)/Library/Application\ Support/ShowTouch

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += showtouch
include $(THEOS_MAKE_PATH)/aggregate.mk
