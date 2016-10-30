#import <vector>
#import <notify.h>
#import <Social/Social.h>
#import "prefs.h"

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.mibandalert.plist"
#define kVibrateMiBandNotification "com.julioverne.mibandalert/Vibrate"

@interface MiBandAlertSettingsController : PSListController {
	UILabel* _label;
	UILabel* underLabel;
}
- (void)HeaderCell;
@end

@implementation MiBandAlertSettingsController
- (id)specifiers {
	if (!_specifiers) {
		NSMutableArray* specifiers = [NSMutableArray array];
		PSSpecifier* spec;
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                  target:self
											         set:@selector(setPreferenceValue:specifier:)
											         get:@selector(readPreferenceValue:)
                                                  detail:Nil
											        cell:PSSwitchCell
											        edit:Nil];
		[spec setProperty:@"Enabled" forKey:@"key"];
		[spec setProperty:@YES forKey:@"default"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Notification"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Notification" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled For All Apps"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSwitchCell
											  edit:Nil];
		[spec setProperty:@"AllAlerts" forKey:@"key"];
		[spec setProperty:@YES forKey:@"UpdateAppCell"];
		[spec setProperty:@NO forKey:@"default"];
        [specifiers addObject:spec];		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled For Apps"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
		if (access("/System/Library/PreferenceBundles/AppList.bundle", F_OK) == 0) {
			[spec setProperty:@YES forKey:@"isContoller"];
			[spec setProperty:@YES forKey:@"ALAllowsSelection"];			 
			[spec setProperty:@"AppList" forKey:@"bundle"];
			[spec setProperty:@"/System/Library/PreferenceBundles/AppList.bundle" forKey:@"lazy-bundle"];
			[spec setProperty:@"" forKey:@"ALSettingsKeyPrefix"];
			[spec setProperty:@"com.julioverne.mibandalert/Settings" forKey:@"ALChangeNotification"];
			[spec setProperty:@PLIST_PATH_Settings forKey:@"ALSettingsPath"];
			[spec setProperty:@NO forKey:@"ALSettingsDefaultValue"];
			[spec setProperty:@[
			@{
				@"title": @"System Applications",
				@"predicate": @"(isSystemApplication = TRUE)",
				@"cell-class-name": @"ALSwitchCell",
				@"icon-size": @29,
				@"suppress-hidden-apps": @1,
			},
			@{
				@"title": @"User Applications",
				@"predicate": @"(isSystemApplication = FALSE)",
				@"cell-class-name": @"ALSwitchCell",
				@"icon-size": @29,
				@"suppress-hidden-apps": @1,
			}] forKey:@"ALSectionDescriptors"];
			
			spec->action = @selector(lazyLoadBundle:);
		}
		[spec setProperty:@(![[self readPreferenceValue:[specifiers lastObject]] boolValue]) forKey: @"enabled"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Follow DoNotDisturb Mode"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSwitchCell
											  edit:Nil];
		[spec setProperty:@"MiBandDoNotDisturb" forKey:@"key"];
		[spec setProperty:@YES forKey:@"default"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Vibrate Without Led"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSwitchCell
											  edit:Nil];
		[spec setProperty:@"MiBandLedOff" forKey:@"key"];
		[spec setProperty:@NO forKey:@"default"];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Device Low Battery Alert"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Device Low Battery Alert" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSwitchCell
											  edit:Nil];
		[spec setProperty:@"LowBaterry" forKey:@"key"];
		[spec setProperty:@YES forKey:@"UpdateBattCell"];
		[spec setProperty:@NO forKey:@"default"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Level"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"LowBaterryLevel" forKey:@"key"];
		[spec setProperty:@(20) forKey:@"default"];
		[spec setProperty:@0 forKey:@"min"];
		[spec setProperty:@(100) forKey:@"max"];
		[spec setProperty:@NO forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"isSegmented"];
		[spec setProperty:@YES forKey:@"showValue"];
		[spec setProperty:@([[self readPreferenceValue:[specifiers lastObject]] boolValue]) forKey: @"enabled"];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Activator"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Activator" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Activation Method"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
		if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
			[spec setProperty:@YES forKey:@"isContoller"];
			[spec setProperty:@"com.julioverne.mibandalert" forKey:@"activatorListener"];
			[spec setProperty:@"/System/Library/PreferenceBundles/LibActivator.bundle" forKey:@"lazy-bundle"];
			spec->action = @selector(lazyLoadBundle:);
		}
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Connection Guide"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Connection Guide" forKey:@"label"];
		[spec setProperty:@"1. Install 'Mi Fit' on AppStore.\n2. Open 'Mi Fit' go to Settings MiBand on 'Mi Fit' and Enable Vibrate to Received Calls (to keep your  Mi Band payred with BlueTooth).\n3. Test your MiBand Vibrate above." forKey:@"footerText"];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Test Vibrate Alert Mi Band"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(vibrate);
        [specifiers addObject:spec];
		/*spec = [PSSpecifier preferenceSpecifierNamed:@"Respring (if you have problem)"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(respring);
        [specifiers addObject:spec];*/
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Developer"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Developer" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Follow julioverne"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(twitter);
		[spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
		[spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"twitter" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
		spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"MiBandAlert by julioverne © 2015" forKey:@"footerText"];
        [specifiers addObject:spec];
		_specifiers = [specifiers copy];
	}
	return _specifiers;
}

/*- (void)respring
{
	system("killall -9 backboardd SpringBoard");
}*/
- (void)vibrate
{
	notify_post(kVibrateMiBandNotification);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title 
                                                    message:@"Your Mi Band Will Vibrate Now." 
                                                    delegate:nil 
                                                    cancelButtonTitle:@"OK" 
                                                    otherButtonTitles:nil];
    [alert show];
}
- (void)twitter
{
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]];
	} else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]];		
	} else {
		[app openURL:[NSURL URLWithString:@"https://mobile.twitter.com/ijulioverne"]];
	}
}
- (void)love
{
	SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[twitter setInitialText:@"#MiBandAlert by @ijulioverne is cool!"];
	if (twitter != nil) {
		[[self navigationController] presentViewController:twitter animated:YES completion:nil];
	}
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	@autoreleasepool {
		NSMutableDictionary *CydiaEnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		[CydiaEnablePrefsCheck setObject:value forKey:[specifier identifier]];
		[CydiaEnablePrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.mibandalert/Settings");

		if ([[specifier properties] objectForKey:@"UpdateAppCell"]) {
			if (PSSpecifier* cellApp = [self specifierAtIndex:4]) {
				if ([[cellApp properties] objectForKey:@"ALAllowsSelection"]) {
					[cellApp setProperty:@(![value boolValue]) forKey: @"enabled"];
					[self reloadSpecifierAtIndex:4 animated:YES];
				}
			}
		} else if ([[specifier properties] objectForKey:@"UpdateBattCell"]) {
			if (PSSpecifier* cellApp = [self specifierAtIndex:9]) {
				[cellApp setProperty:@([value boolValue]) forKey: @"enabled"];
				[self reloadSpecifierAtIndex:9 animated:YES];
			}
		}
	}
}
- (id)readPreferenceValue:(PSSpecifier*)specifier
{
	@autoreleasepool {
		NSDictionary *CydiaEnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings];
		return CydiaEnablePrefsCheck[[specifier identifier]]?:[[specifier properties] objectForKey:@"default"];
	}
}
- (void)_returnKeyPressed:(id)arg1
{
	[super _returnKeyPressed:arg1];
	[self.view endEditing:YES];
}

- (void)HeaderCell
{
	@autoreleasepool {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
	int width = [[UIScreen mainScreen] bounds].size.width;
	CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect botFrame = CGRectMake(0, 55, width, 60);
 
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
		[_label setText:self.title];
		[_label setBackgroundColor:[UIColor clearColor]];
		_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 0;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"System Notification XiaoMi Mi Band for iOS"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;
		underLabel.alpha = 0;
		
		[headerView addSubview:_label];
		[headerView addSubview:underLabel];
		
	[_table setTableHeaderView:headerView];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(increaseAlpha)
                                   userInfo:nil
                                    repeats:NO];
				
	}
}
- (void) loadView
{
	[super loadView];
	self.title = @"MiBand Alert";
	[self HeaderCell];	
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.09 green:0.99 blue:0.99 alpha:1.0];
	UIButton *heart = [[UIButton alloc] initWithFrame:CGRectZero];
	[heart setImage:[[UIImage alloc] initWithContentsOfFile:[[self bundle] pathForResource:@"Heart" ofType:@"png"]] forState:UIControlStateNormal];
	[heart sizeToFit];
	[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:heart];
}
- (void)increaseAlpha
{
	[UIView animateWithDuration:0.5 animations:^{
		_label.alpha = 1;
	}completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			underLabel.alpha = 1;
		}completion:nil];
	}];
}				
@end