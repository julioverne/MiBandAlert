#import <Foundation/Foundation.h>

@class MBALCentralManager, MBALPeripheral;

typedef NS_ENUM(int, MBServiceType) {
    MBServiceTypeDefault = 0x1802
};

typedef void(^MBStateUpdatedBlock)(MBALCentralManager *manager);
typedef void(^MBConnectResultBlock)(MBALPeripheral *peripheral, NSError *error);
typedef void(^MBDiscoverPeripheralBlock)(MBALPeripheral *miband, NSNumber *RSSI, NSError *error);

@interface MBALCentralManager : NSObject

@property (nonatomic, getter=isScanning, readonly) BOOL scanning;
@property (nonatomic, strong, readonly) NSArray *peripherals;
@property (nonatomic, copy) MBStateUpdatedBlock poweredOnBlock;
@property (nonatomic, copy) MBStateUpdatedBlock poweredOffBlock;
@property (nonatomic, copy) MBConnectResultBlock disconnectedBlock;

+ (instancetype)sharedCentralManager;
- (void)scanForMiBandWithBlock:(MBDiscoverPeripheralBlock)discoverPeripheralBlock;
- (void)connectPeripheral:(MBALPeripheral *)peripheral withResultBlock:(MBConnectResultBlock)resultBlock;
- (void)stopScan;

@end
