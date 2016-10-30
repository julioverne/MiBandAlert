#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <notify.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <substrate.h>

#import "MiBandAlertController.h"

#define kMibandController [MiBandAlertController mibandSharedInstance]
#define kPreferenceChangedNotification "com.julioverne.mibandalert/Settings"
#define kVibrateMiBandNotification "com.julioverne.mibandalert/Vibrate"

#define kPreferenceDictionary [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.julioverne.mibandalert.plist"]

@interface MiBandAlertController ()
@property (nonatomic) MBALPeripheral *myPeripheral;
@end

static BOOL Enabled;
static BOOL AllAlerts;
static BOOL doNotDisturbEnabled;
static BOOL MiBandDoNotDisturb;
static BOOL LowBaterryAlert;
static int LowBaterryLevel;
static int BaterryLevelOld;
int MiBandLedOff = 0;
static __strong NSDictionary* PrefsDocMiBand;
static __strong NSString* kNone = @"";

static void MiBandAlertLoadPreferences()
{
	PrefsDocMiBand = [kPreferenceDictionary?:[NSDictionary dictionary] copy];
	Enabled = (BOOL)[[PrefsDocMiBand objectForKey:@"Enabled"]?:@YES boolValue];
	AllAlerts = (BOOL)[[PrefsDocMiBand objectForKey:@"AllAlerts"]?:@NO boolValue];
	LowBaterryAlert = (BOOL)[[PrefsDocMiBand objectForKey:@"LowBaterry"]?:@NO boolValue];
	LowBaterryLevel = (int)[[PrefsDocMiBand objectForKey:@"LowBaterryLevel"]?:@(20) intValue];
	MiBandDoNotDisturb = (BOOL)[[PrefsDocMiBand objectForKey:@"MiBandDoNotDisturb"]?:@YES boolValue];
	MiBandLedOff = [[PrefsDocMiBand objectForKey:@"MiBandLedOff"]?:@NO boolValue]?1:0;
}

static void MiBandAlertVibrate()
{
	if ([[kMibandController dkPeripheral] isConnected]){
		[[kMibandController dkPeripheral] makeBandVibrateWithBlock:^(NSError *error) { }];
	} else {
		[[kMibandController currentCentralManager] scanForMiBandWithBlock:^(MBALPeripheral *miband, NSNumber *RSSI, NSError *error) {
			[[kMibandController currentCentralManager] stopScan];
			kMibandController.myPeripheral = [kMibandController currentCentralManager].peripherals[0];
			[[kMibandController currentCentralManager] connectPeripheral:kMibandController.myPeripheral withResultBlock:^(MBALPeripheral *peripheral, NSError *error) {
				if (error) {
					return NSLog(@"[MiBandAlertController] ERROR -> %@", [error localizedDescription]);
				} else {
					[[kMibandController dkPeripheral] makeBandVibrateWithBlock:^(NSError *error) { }];
				}
			}];
		}];		
	}
}

static void MiBandAlertLowBattery()
{
	if(Enabled && LowBaterryAlert) {
		int battlevel = (int)([[UIDevice currentDevice] batteryLevel] * 100);
		if(!(MiBandDoNotDisturb && doNotDisturbEnabled)) {
			if((LowBaterryLevel == battlevel) && (BaterryLevelOld > battlevel) ) {
				notify_post(kVibrateMiBandNotification);
			}
		}
		BaterryLevelOld = battlevel;
	}
}

%group MiBandAlertHooks
%hook SBCCDoNotDisturbSetting
-(void)_setDNDEnabled:(BOOL)arg1 updateServer:(BOOL)arg2 source:(unsigned long long)arg3
{
	doNotDisturbEnabled = arg1;
	%orig();
}
%end
%hook BBServer
- (void)_publishBulletinRequest:(id)request forSectionID:(NSString *)sectionID forDestinations:(unsigned long long)destination alwaysToLockScreen:(_Bool)onLockscreen
{
	%orig();
	if (Enabled && !(MiBandDoNotDisturb && doNotDisturbEnabled) ) {
		if (AllAlerts) {
			notify_post(kVibrateMiBandNotification);
		} else if ([[PrefsDocMiBand objectForKey:sectionID?:kNone]?:@NO boolValue]) {
			notify_post(kVibrateMiBandNotification);
		}
	}
}
%end

/*%hook CBPeripheral
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type
{
	NSLog(@"***\n************ CBPeripheral: data: %@\n characteristic: %@\nservice.UUID: %@\n", data, characteristic, characteristic.service.UUID);
	%orig(data, characteristic, type);
}
%end*/

%end



#import <libactivator/libactivator.h>
@interface MiBandAlertActivator : NSObject
+ (id)sharedInstance;
- (void)RegisterActions;
@end

@implementation MiBandAlertActivator
+ (id)sharedInstance
{
    __strong static id _sharedObject;
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
- (void)RegisterActions
{
    if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
		dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	    if (Class la = objc_getClass("LAActivator")) {
			[[la sharedInstance] registerListener:(id<LAListener>)self forName:@"com.julioverne.mibandalert"];
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"MiBand Alert";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Make MiBand Vibrate";
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/MiBandAlertSettings.bundle"] pathForResource:scale==2.0f?@"MiBandAlert@2x":@"MiBandAlert" ofType:@"png"]];
	}
    return listenerIcon;
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/MiBandAlertSettings.bundle"] pathForResource:scale==2.0f?@"MiBandAlert@2x":@"MiBandAlert" ofType:@"png"]];
	}
    return listenerIcon;
}
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (Enabled && !(MiBandDoNotDisturb && doNotDisturbEnabled) ) {
		notify_post(kVibrateMiBandNotification);
	}
}
@end

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)MiBandAlertLowBattery, (CFStringRef)UIDeviceBatteryLevelDidChangeNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)MiBandAlertLoadPreferences, CFSTR(kPreferenceChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)MiBandAlertVibrate, CFSTR(kVibrateMiBandNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	MiBandAlertLoadPreferences();
	//if (Enabled) {
		[kMibandController loadCentralManager];
		%init(MiBandAlertHooks);
	//}
	[[MiBandAlertActivator sharedInstance] RegisterActions];
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
}



