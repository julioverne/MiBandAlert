#import <Foundation/Foundation.h>

@class CBPeripheral, CBService;
@class MBALCentralManager;

typedef NS_ENUM(NSInteger, MBCharacteristicType) {
    MBCharacteristicTypeDeviceInfo = 0x2A01,
    MBCharacteristicTypeDeviceName,         //0xFF02
    MBCharacteristicTypeNotification,       //0xFF03
    MBCharacteristicTypeUserInfo,           //0xFF04
    MBCharacteristicTypeControl,            //0xFF05
    MBCharacteristicTypeRealtimeSteps,      //0xFF06
    MBCharacteristicTypeActivityData,       //0xFF07
    MBCharacteristicTypeFirmwareData,       //0xFF08
    MBCharacteristicTypeLEParams,           //0xFF09
    MBCharacteristicTypeDateTime,           //0xFF0A
    MBCharacteristicTypeStatistics,         //0xFF0B
    MBCharacteristicTypeBatteryInfo,        //0xFF0C
    MBCharacteristicTypeTest,               //0xFF0D
    MBCharacteristicTypeSensorData          //0xFF0E
};

typedef NS_OPTIONS(NSInteger, MBControlPoint) {
    MBControlPointStopCallRemind = 0,
    MBControlPointCallRemind,
    MBControlPointRealtimeSetpsNotification = 3,
    MBControlPointTimer,
    MBControlPointGoal,
    MBControlPointFetchData,
    MBControlPointFirmwareInfo,
    MBControlPointSendNotification,
    MBControlPointReset,
    MBControlPointConfirmData,
    MBControlPointSync,
    MBControlPointReboot = 12,
    MBControlPointColor = 14,
    MBControlPointWearPosition,
    MBControlPointRealtimeSteps,
    MBControlPointStopSync,
    MBControlPointSensorData,
    MBControlPointStopVibrate
};

typedef NS_ENUM(NSInteger, MBNotificationType) {
    MBNotificationTypeNormal = 0,
    MBNotificationTypeCall
};

typedef NS_ENUM(NSInteger, MBWearPosition) {
    MBWearPositionLeft = 0,
    MBWearPositionRight
};

typedef void(^MBDiscoverServicesResultBlock)(NSArray *services, NSError *error);
typedef void(^MBDiscoverCharacteristicsResultBlock)(NSArray *characteristics, NSError *error);
typedef void(^MBRealtimeStepsResultBlock)(NSUInteger steps, NSError *error);
typedef void(^MBActivityDataHandleBlock)(NSArray *array, NSError *error);

typedef void(^MBALPeripheralReadValueResultBlock)(NSData *data, NSError *error);
typedef void(^MBALPeripheralWriteValueResultBlock)(NSError *error);


@interface MBALPeripheral : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, getter=isConnected, readonly) BOOL connected;
@property (nonatomic, weak) MBALCentralManager *centralManager;
@property (nonatomic, strong) CBService *service;

@property (nonatomic, strong, readonly) CBPeripheral *cbPeripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)cbPeripheral centralManager:(MBALCentralManager *)manager;
- (void)discoverServices:(NSArray *)serviceUUIDs withBlock:(MBDiscoverServicesResultBlock)block;
- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service withBlock:(MBDiscoverCharacteristicsResultBlock)block;

- (void)makeBandVibrateWithBlock:(MBALPeripheralWriteValueResultBlock)block;

@end
