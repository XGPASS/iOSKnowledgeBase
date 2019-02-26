//
//  SCBleCenterManager.m
//  SCBle
//
//  Created by Jianying Wan on 2017/4/10.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import "SCBleCenterManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SCBlePeripheralManager.h"
#import "SCPeripheralObject.h"

NSString * const KNotificationOpenBleDoor = @"KNotificationOpenBleDoor";

@interface SCBleCenterManager () <CBCentralManagerDelegate>
@property (strong, nonatomic) NSMutableArray<SCBlePeripheralManager *> *peripheralManagers; //每一个外设都有一个mac
@end

@implementation SCBleCenterManager {
    NSTimer *_scanTimer;
}

+ (instancetype)sharedManager {
    static SCBleCenterManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SCBleCenterManager alloc] init];
    });
    
    return _manager;
}


#pragma mark - Lazy Load

- (NSMutableArray<SCPeripheralObject *> *)peripherals {
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (NSMutableArray<SCBlePeripheralManager *> *)peripheralManagers {
    if (!_peripheralManagers) {
        _peripheralManagers = [NSMutableArray array];
    }
    
    return _peripheralManagers;
}

#pragma mark - Private Methods 

///开始扫描
- (void)startScanPeripheral {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    CBUUID *serviceUuid = [CBUUID UUIDWithString:doorServiceUuid];
    [self.centralManager scanForPeripheralsWithServices:@[serviceUuid] options:nil];
    
    if (_scanTimer) {
        [_scanTimer invalidate];
        _scanTimer = nil;
    }
    
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(actionBleScanFinished:) userInfo:nil repeats:NO];
}

///扫描结束
- (void)actionBleScanFinished:(id)sender {
    NSLog(@"scan finished");
    [self.centralManager stopScan];
    [self.peripherals sortUsingComparator:^NSComparisonResult(SCPeripheralObject *peripheralObj1, SCPeripheralObject *peripheralObj2) {
        ///信号强的在前面，RSSI为负值 越接近0信号越好
        return [peripheralObj2.RSSI compare:peripheralObj1.RSSI];
    }];
    
    /* 同时开多片门
    for (SCPeripheralObject *peripheralObj in self.peripherals) {
        SCBlePeripheralManager *manager = [[SCBlePeripheralManager alloc] initWithPeripheral:peripheralObj];
        __weak CBCentralManager *weakCentralManager = self.centralManager;
        manager.openSuccessBlock = ^(CBPeripheral *peripheral) {
            [weakCentralManager cancelPeripheralConnection:peripheral];
        };
        [self.peripheralManagers addObject:manager];
        [self.centralManager connectPeripheral:peripheralObj.peripheral options:nil];
    }
     */
    
    //只开一片门
    if (self.peripherals.count > 0) {
        SCPeripheralObject *peripheralObj = self.peripherals[0];
        SCBlePeripheralManager *manager = [[SCBlePeripheralManager alloc] initWithPeripheral:peripheralObj];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationOpenBleDoor object:peripheralObj.randomValueWithMacAddress];
        __weak CBCentralManager *weakCentralManager = self.centralManager;
        manager.openSuccessBlock = ^(CBPeripheral *peripheral) {
            [weakCentralManager cancelPeripheralConnection:peripheral];
        };
        [self.peripheralManagers addObject:manager];
        [self.centralManager connectPeripheral:peripheralObj.peripheral options:nil];
    }
}

///从外设的广播中截取随机值和mac地址
- (NSString *)randomValueWithMacValueFromManufacturerData:(NSData *)manuFacturerData {
    
    if (!manuFacturerData) {
        return @"";     //广播数据不正确
    }
    else {
        NSMutableString *strData = [NSMutableString stringWithString:manuFacturerData.description];
        [strData deleteCharactersInRange:NSMakeRange(0, 5)];
        [strData deleteCharactersInRange:NSMakeRange(strData.length-1, 1)];
        [strData replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strData.length)];
        
        return strData;
    }
    
    //return @"a3d5e6f4de8ce20c279d";
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"central.state = %ld", (long)central.state);
    if (central.state == CBManagerStatePoweredOn) {
        CBUUID *serviceUuid = [CBUUID UUIDWithString:doorServiceUuid];
        [self.centralManager scanForPeripheralsWithServices:@[serviceUuid] options:nil];
    }
    else {
        NSLog(@"蓝牙未开启");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"data -- %@", advertisementData);
    NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
    NSString *strRandomWithMacAddress = [self randomValueWithMacValueFromManufacturerData:manufacturerData];

    SCPeripheralObject *peripheralObj = [[SCPeripheralObject alloc] initWithPeripheral:peripheral aesKey:nil randomValueWithMacAddress:strRandomWithMacAddress RSSI:RSSI];
    if (![self.peripherals containsObject:peripheralObj]) {
        [self.peripherals addObject:peripheralObj];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];  //读取service
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"fail --- %@", error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"disconnect --- %@", error);
}

@end
