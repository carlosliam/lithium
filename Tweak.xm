#include "LTMPrefsManager.m"
#include "UIImage+RenderBatteryImage.m"

@interface NSUserDefaults (Lithium)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *n = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"lithiumEnabled" inDomain:@"lithium"];
	if(n) [LTMPrefsManager sharedManager].enabled = [n boolValue];
	NSString *theme = [[NSUserDefaults standardUserDefaults] objectForKey:@"lithiumTheme" inDomain:@"lithium"];
	if(theme) [LTMPrefsManager sharedManager].theme = (NSMutableString*)theme;
	/*
	SCD_Struct_UI69 data = MSHookIvar<SCD_Struct_UI69>([LTMPrefsManager sharedManager].data, "_rawData");
	data.batteryCapacity = 0;
	UIStatusBarComposedData *composedData = [[%c(UIStatusBarComposedData) alloc] initWithRawData:&data];
	UIStatusBarComposedData *originalData = [LTMPrefsManager sharedManager].data;
	[[LTMPrefsManager sharedManager].batteryView updateForNewData:composedData actions:0];
	SEL selector = NSSelectorFromString(@"updateForNewData:actions:");
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[LTMPrefsManager sharedManager].batteryView methodSignatureForSelector:selector]];
	[invocation setSelector:selector];
	[invocation setTarget:[LTMPrefsManager sharedManager].batteryView];
	[invocation setArgument:&(originalData) atIndex:2];
	[invocation setArgument:0 atIndex:3];
	[invocation performSelector:@selector(invoke) withObject:nil afterDelay:0];*/
	/*
	[composedData release];
	[originalData release];*/
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, notificationCallback, (CFStringRef)@"lithium.prefs-changed", nil, CFNotificationSuspensionBehaviorCoalesce);
}

%hook UIStatusBarBatteryItemView


/*
- (BOOL)updateForNewData:(UIStatusBarComposedData*)data actions:(int)actions {
	[LTMPrefsManager sharedManager].data = data;
	return %orig;
}*/
- (BOOL)_needsAccessoryImage {
	return ([LTMPrefsManager sharedManager].enabled) ? NO : %orig;
}

- (id)contentsImage {
	// if(![LTMPrefsManager sharedManager].batteryView) [LTMPrefsManager sharedManager].batteryView = self;
	if([LTMPrefsManager sharedManager].enabled) {
		int level = MSHookIvar<int>(self, "_capacity");
		int state = MSHookIvar<int>(self, "_state");
		CGFloat height = MSHookIvar<CGFloat>([self foregroundStyle], "_height") * [UIScreen mainScreen].scale;
		UIImage *image = [UIImage renderBatteryImageForJavaScript:[LTMPrefsManager sharedManager].script height:height percentage:level charging:state color:[[self foregroundStyle] textColorForStyle:[self legibilityStyle]]];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:image];
	}
	else {
		return %orig;
	}
}

%end