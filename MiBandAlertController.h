#import <UIKit/UIKit.h>
#import "MiBand/MiBand.h"

@interface MiBandAlertController : NSObject
+ (MiBandAlertController *)mibandSharedInstance;
- (MBALCentralManager *)currentCentralManager;
- (void)loadCentralManager;
- (void)scanForMiBand;
- (MBALPeripheral *)dkPeripheral;
@end