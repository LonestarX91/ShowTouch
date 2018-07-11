#import <UIKit/UIKit.h>
#import <libcolorpicker.h>

#define kIdentifier @"com.lnx.showtouch"
#define kSettingsChangedNotification (CFStringRef)@"com.lnx.showtouch/ReloadPrefs"
#define kColorChangedNotification (CFStringRef)@"com.lnx.showtouch/colorChanged"
#define kSettingsResetNotification (CFStringRef)@"com.lnx.showtouch/settingsReset"

#define kColorPath @"/var/mobile/Library/Preferences/com.lnx.showtouch.color.plist"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.lnx.showtouch.plist"


static UIWindow *touchWindow;
static CAShapeLayer *circleShape;
static UIColor *touchColor;
static UIColor *rippleColor;
static BOOL enabled;
static CGFloat touchSize;
static NSTimer *hideTimer;

%hook UIWindow
-(BOOL)_ignoresHitTest {
  return (self == touchWindow) ? YES : %orig;
}

-(void)sendEvent:(UIEvent *)event {
  %orig;
  if (enabled) {
    if (self != touchWindow) {
      if (event.type == UIEventTypeTouches) {
        for(UITouch *touch in [event allTouches]) {
          CGPoint point = [touch locationInView:nil];
          if(touch.phase == UITouchPhaseBegan) {
            if (!touchWindow) {
                touchWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, touchSize, touchSize)];
            }
            CGRect touchFrame = touchWindow.bounds;
            touchFrame.size.width = touchFrame.size.height = touchSize;
            touchWindow.bounds = touchFrame;
            touchWindow.backgroundColor = touchColor;
            touchWindow.center = point;
            touchWindow.windowLevel = UIWindowLevelStatusBar + 100000;
            touchWindow.userInteractionEnabled = NO;
            touchWindow.layer.cornerRadius = touchWindow.bounds.size.width / 2;
            touchWindow.hidden = NO;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:touchWindow.bounds cornerRadius:touchWindow.layer.cornerRadius];
            [circleShape removeFromSuperlayer];
            circleShape = [CAShapeLayer layer];
            circleShape.bounds = touchWindow.bounds;
            circleShape.path = path.CGPath;
            circleShape.position = CGPointMake(touchSize/2, touchSize/2);
            circleShape.fillColor = rippleColor.CGColor;
            circleShape.opacity = 0;
            circleShape.strokeColor = rippleColor.CGColor;
            circleShape.lineWidth = 0.5;
            circleShape.anchorPoint = CGPointMake(.5,.5);
            circleShape.contentsGravity = @"center";
            if (touchWindow.layer.sublayers.count == 0) {
              [touchWindow.layer addSublayer:circleShape];
            }
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
            }];

            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 1, 1)];

            CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            alphaAnimation.fromValue = @0.7;
            alphaAnimation.toValue = @0;

            CAAnimationGroup *animation = [CAAnimationGroup animation];
            animation.animations = @[scaleAnimation, alphaAnimation];
            animation.duration = 0.5;
            animation.repeatCount = 1;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [circleShape addAnimation:animation forKey:nil];
            [CATransaction commit];
          }
          else if (touch.phase == UITouchPhaseMoved) {
            touchWindow.center = point;
            touchWindow.hidden = NO;
          }
          else if (touch.phase == UITouchPhaseEnded) {
            if ([hideTimer isValid]) {
              [hideTimer invalidate];
              hideTimer = nil;
            }
            hideTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:NO block:^(NSTimer * _Nonnull timer) {
              touchWindow.hidden = YES;
            }];
          }
        }
      }
    }
  }
}
%end

static void reloadColorPrefs() {
	NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kColorPath];
	touchColor = [preferences objectForKey:@"touchColor"] ? LCPParseColorString([preferences objectForKey:@"touchColor"], @"#FFFFFF") : [UIColor redColor];
  rippleColor = [preferences objectForKey:@"rippleColor"] ? LCPParseColorString([preferences objectForKey:@"rippleColor"], @"#FFFFFF") : [UIColor redColor];
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

	enabled = [prefs objectForKey:@"enabled"] ? [(NSNumber *)[prefs objectForKey:@"enabled"] boolValue] : false;
  touchSize = [prefs objectForKey:@"touchSize"] ? [[prefs objectForKey:@"touchSize"] floatValue] : 30;
}

%ctor {
	reloadPrefs();
	reloadColorPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadColorPrefs, kColorChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
