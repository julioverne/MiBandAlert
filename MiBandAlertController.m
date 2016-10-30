#import <CoreBluetooth/CoreBluetooth.h>
#import "MiBandAlertController.h"

@interface MiBandAlertController ()
@property (nonatomic) MBALPeripheral *myPeripheral;
@end

static __strong __typeof(MBALCentralManager *) centralManager;

@implementation MiBandAlertController
- (MBALCentralManager *)currentCentralManager
{
	return centralManager;
}
+ (MiBandAlertController *)mibandSharedInstance {
	static __strong MiBandAlertController *wSharedInstance;
    if (wSharedInstance == nil){
        @synchronized(self){
            if (wSharedInstance == nil){
                wSharedInstance = [self new];
                return wSharedInstance;
            }
        }
    }
    return wSharedInstance;
}
- (void)loadCentralManager
{
	// create centralManager.
	centralManager = [MBALCentralManager sharedCentralManager];
	// get peripheral on powern on, after scan.
    [centralManager setPoweredOnBlock:^(MBALCentralManager *manager) {
        [self scanForMiBand];
    }];
    [centralManager setPoweredOffBlock:^(MBALCentralManager *manager) {
        [manager stopScan];
    }];
    [centralManager setDisconnectedBlock:^(MBALPeripheral *peripheral, NSError *error) {
        // null.
    }];
}
- (void)scanForMiBand
{
    // get peripheral after scan.
    [centralManager scanForMiBandWithBlock:^(MBALPeripheral *miband, NSNumber *RSSI, NSError *error) {
        [centralManager stopScan];

        self->_myPeripheral = centralManager.peripherals[0];
			
        [centralManager connectPeripheral:_myPeripheral withResultBlock:^(MBALPeripheral *peripheral, NSError *error) {
            if (error) {
                return NSLog(@"[MiBandAlertController] ERROR -> %@", [error localizedDescription]);
            }
        }];
    }];
}
- (MBALPeripheral *)dkPeripheral
{
	return _myPeripheral;
}
@end