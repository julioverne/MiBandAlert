#import "MBALPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MBALPeripheral ()<CBPeripheralDelegate>
@property (nonatomic, copy) MBDiscoverServicesResultBlock discoverServicesBlock;
@property (nonatomic, copy) MBDiscoverCharacteristicsResultBlock discoverCharacteristicsBlock;
@end

extern int MiBandLedOff;

@implementation MBALPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)cbPeripheral centralManager:(MBALCentralManager *)manager
{
    self = [super init];
    if (self) {
        _cbPeripheral = cbPeripheral;
        _centralManager = manager;
        _cbPeripheral.delegate = self;
    }
    return self;
}

- (NSString *)name
{
    return _cbPeripheral.name;
}

- (BOOL)isConnected
{
    return self.cbPeripheral.state == CBPeripheralStateConnected;
}

#pragma mark - Public Methods
- (void)discoverServices:(NSArray *)serviceUUIDs withBlock:(MBDiscoverServicesResultBlock)block
{
    self.discoverServicesBlock = block;
    [self.cbPeripheral discoverServices:serviceUUIDs];
}

- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service withBlock:(MBDiscoverCharacteristicsResultBlock)block
{
    if (service) {
		self.discoverCharacteristicsBlock = block;
        [self.cbPeripheral discoverCharacteristics:characteristicUUIDs forService:service];
    }
}



- (void)makeBandVibrateWithBlock:(MBALPeripheralWriteValueResultBlock)block
{
	@autoreleasepool {
		for(CBService *service in self.cbPeripheral.services) {
			for(CBCharacteristic *charac in service.characteristics) {
				[self.cbPeripheral writeValue:[NSData dataWithBytes:MiBandLedOff==1?"\x04":"\x03" length:1] forCharacteristic:charac type:CBCharacteristicWriteWithoutResponse];
			}
		}
	}
}




#pragma mark - CBPeripheralDelegate Methods
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    self.service = [peripheral.services firstObject];
    if (self.discoverServicesBlock) {
        self.discoverServicesBlock(peripheral.services, error);
        self.discoverServicesBlock = nil;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{   
    if (self.discoverCharacteristicsBlock) {
        self.discoverCharacteristicsBlock(service.characteristics, error);
        self.discoverCharacteristicsBlock = nil;
    }
}



@end
