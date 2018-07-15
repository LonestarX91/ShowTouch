#include "SWTRootListController.h"
#import <UIKit/UIKit.h>

#define kColorPath @"/var/mobile/Library/Preferences/com.lnx.showtouch.color.plist"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.lnx.showtouch.plist"
#define kSettingsChangedNotification (CFStringRef)@"com.lnx.showtouch/ReloadPrefs"
#define kColorChangedNotification (CFStringRef)@"com.lnx.showtouch/colorChanged"

#define prefsAppID CFSTR("com.lnx.showtouch")
#define prefsAppIDColor CFSTR("com.lnx.showtouch.color")

@implementation SWTRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void)openPaypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/lonestarx1"] options:[NSDictionary new] completionHandler:nil];
}

- (void)openTwitter {
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=lonestarx"] options:[NSDictionary new] completionHandler:nil];
    else
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/LonestarX"] options:[NSDictionary new] completionHandler:nil];
}

- (void)sendMail {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:me@lonestarx.net"] options:[NSDictionary new] completionHandler:nil];
}
@end
