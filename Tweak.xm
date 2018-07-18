#import <UIKit/UIKit.h>
#import <libcolorpicker.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>

typedef void (^DarwinNotificationBlock)(NSString *identifier);


#define kIdentifier @"com.lnx.showtouch"
#define kSettingsChangedNotification (CFStringRef)@"com.lnx.showtouch/ReloadPrefs"
#define kScreenRecordChanged (CFStringRef)@"captured"
#define kColorChangedNotification (CFStringRef)@"com.lnx.showtouch/colorChanged"
#define kSettingsResetNotification (CFStringRef)@"com.lnx.showtouch/settingsReset"

#define kColorPath @"/var/mobile/Library/Preferences/com.lnx.showtouch.color.plist"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.lnx.showtouch.plist"

@interface TouchWindow : UIWindow
@property (nonatomic, strong) NSTimer *hideTimer;
@end
@implementation TouchWindow
-(BOOL)_ignoresHitTest {
  return YES;
}
@end
static TouchWindow *touchWindow1;
static TouchWindow *touchWindow2;
static TouchWindow *touchWindow3;

static CAShapeLayer *circleShape;
static UIColor *touchColor;
static NSInteger enabled;

static CGFloat touchSize;
static BOOL receivedAppNotification;
@interface UITouchesEvent : UIEvent
@end

@interface UIApplication (STUIApp)
-(SBApplication*)_accessibilityFrontMostApplication;
@end

%hook UITouchesEvent

-(void)_setHIDEvent:(id)arg1 {
  if (enabled == 1){
    dispatch_async(dispatch_get_main_queue(), ^{

      SBApplication *currentApplication = [[objc_getClass("SpringBoard") sharedApplication] _accessibilityFrontMostApplication];
      NSLog(@"APP: %@ - %@", currentApplication, [UIApplication sharedApplication]);
    // if ([[UIApplication sharedApplication] isKindOfClass:%c(SpringBoard)] && receivedAppNotification) {
    //
    //   // CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    //   // CFNotificationCenterPostNotification(center, NULL, NULL, NULL, TRUE);
    //
    // } else {
      // NSLog(@"touch from sb");
      // NSLog(@"touch: %@", [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication]);
      // NSLog(@"app: %@ - front: %@", [UIApplication sharedApplication], [[UIApplication sharedApplication] respondsToSelector:@selector(_accessibilityFrontMostApplication)] ? @YES : @NO);

      NSMutableArray *currentTouches;
      if (@available(iOS 11.0, *)) {
        currentTouches = [[[self valueForKey:@"_allTouchesMutable"] allObjects] mutableCopy];
      } else {
        currentTouches = [[[self valueForKey:@"_touches"] allObjects] mutableCopy];
      }
      if (currentTouches.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
        receivedAppNotification = NO;
        touchWindow1.hidden = YES;
        touchWindow2.hidden = YES;
        touchWindow3.hidden = YES;

        touchWindow1 = nil;
        touchWindow2 = nil;
        touchWindow3 = nil;
        });
      }
      else {
        if (currentTouches.count == 1) {
          touchWindow2.hidden = YES;
          touchWindow2 = nil;
          touchWindow3.hidden = YES;
          touchWindow3 = nil;
        }
        else if (currentTouches.count == 2) {
          touchWindow3.hidden = YES;
          touchWindow3 = nil;
        }

        if (!currentApplication && [UIApplication sharedApplication]) {

        for (int i = 0; i < currentTouches.count; i++) {
          UITouch *touch = currentTouches[i];
          CGPoint touchLocation = [[touch valueForKey:@"_locationInWindow"] CGPointValue];
          switch (i) {
            case 0: {
              dispatch_async(dispatch_get_main_queue(), ^{
                if (!touchWindow1) {
                  touchWindow1 = [[TouchWindow alloc] initWithFrame:CGRectMake(touchLocation.x, touchLocation.y, touchSize, touchSize)];
                }
                CGRect touchFrame = touchWindow1.bounds;
                touchFrame.size.width = touchFrame.size.height = touchSize;
                touchWindow1.bounds = touchFrame;
                touchWindow1.backgroundColor = touchColor;
                touchWindow1.center = CGPointMake(touchLocation.x, touchLocation.y);
                touchWindow1.windowLevel = UIWindowLevelStatusBar + 100000;
                touchWindow1.userInteractionEnabled = NO;
                touchWindow1.layer.cornerRadius = touchWindow1.bounds.size.width / 2;
                touchWindow1.hidden = NO;
              });
              break;
            }
            case 1: {
              dispatch_async(dispatch_get_main_queue(), ^{
                if (!touchWindow2) {
                  touchWindow2 = [[TouchWindow alloc] initWithFrame:CGRectMake(touchLocation.x, touchLocation.y, touchSize, touchSize)];
                }
                CGRect touchFrame = touchWindow2.bounds;
                touchFrame.size.width = touchFrame.size.height = touchSize;
                touchWindow2.bounds = touchFrame;
                touchWindow2.backgroundColor = touchColor;
                touchWindow2.center = CGPointMake(touchLocation.x, touchLocation.y);
                touchWindow2.windowLevel = UIWindowLevelStatusBar + 100000;
                touchWindow2.userInteractionEnabled = NO;
                touchWindow2.layer.cornerRadius = touchWindow2.bounds.size.width / 2;
                touchWindow2.hidden = NO;
              });
              break;
            }
            case 2: {
              dispatch_async(dispatch_get_main_queue(), ^{
                if (!touchWindow3) {
                  touchWindow3 = [[TouchWindow alloc] initWithFrame:CGRectMake(touchLocation.x, touchLocation.y, touchSize, touchSize)];
                }
                CGRect touchFrame = touchWindow3.bounds;
                touchFrame.size.width = touchFrame.size.height = touchSize;
                touchWindow3.bounds = touchFrame;
                touchWindow3.backgroundColor = touchColor;
                touchWindow3.center = CGPointMake(touchLocation.x, touchLocation.y);
                touchWindow3.windowLevel = UIWindowLevelStatusBar + 100000;
                touchWindow3.userInteractionEnabled = NO;
                touchWindow3.layer.cornerRadius = touchWindow3.bounds.size.width / 2;
                touchWindow3.hidden = NO;
              });
              break;
            }
            default:
              break;
          }
        }

        }
    }
  });
  }
  %orig;
}
%end

static void reloadColorPrefs() {
	NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kColorPath];
	touchColor = [preferences objectForKey:@"touchColor"] ? LCPParseColorString([preferences objectForKey:@"touchColor"], @"#FFFFFF") : [UIColor redColor];
}

static void reloadPrefs() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList != nil) {
			prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
			if (prefs == nil)
				prefs = [NSDictionary dictionary];
			CFRelease(keyList);
		}
	} else {
		prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}

	enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] integerValue] : 0;
  touchSize = [prefs objectForKey:@"touchSize"] ? [[prefs objectForKey:@"touchSize"] floatValue] : 30;
}

// void notificationCallback(CFNotificationCenterRef center, void * observer, CFStringRef name, void const * object, CFDictionaryRef userInfo) {
//     // NSString *identifier = (__bridge NSString *)name;
//     NSLog(@"incoming notification: %@", object);
//     receivedAppNotification = YES;
// }

// %hook SpringBoard
// -(void)applicationDidFinishLaunching:(id)application {
// %orig;
// NSArray *args = [[NSProcessInfo processInfo] arguments];
//     if (args != nil && args.count != 0) {
//         NSString *execPath = args[0];
//         if (execPath != nil) {
//             BOOL isSpringBoard = [[execPath lastPathComponent] isEqualToString:@"SpringBoard"];
//             BOOL isApplication = [execPath rangeOfString:@"/Application"].location != NSNotFound;
//             if (isSpringBoard && !isApplication) {
//               CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
//               CFStringRef str = (__bridge CFStringRef)@"touchFromApp";
//               CFNotificationCenterAddObserver(center, (__bridge const void *)(self), notificationCallback, str, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
//
//             }
//         }
//     }
//
// }
// %end
%ctor {
	reloadPrefs();
	reloadColorPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadColorPrefs, kColorChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

  if (enabled == 2) {
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserverForName: UIScreenCapturedDidChangeNotification
            object: nil
            queue: nil
            usingBlock: ^ (NSNotification * notification) {
              enabled = UIScreen.mainScreen.captured ? 1 : 0;
        }];
    } else {
    }
  }
}
