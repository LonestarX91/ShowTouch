include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ShowTouch
ShowTouch_FILES = SWTRootListController.m
ShowTouch_INSTALL_PATH = /Library/PreferenceBundles
ShowTouch_FRAMEWORKS = UIKit
ShowTouch_PRIVATE_FRAMEWORKS = Preferences
ShowTouch_CFLAGS = -fobjc-arc
ShowTouch_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShowTouch.plist$(ECHO_END)
