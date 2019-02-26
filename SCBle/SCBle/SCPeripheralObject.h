//
//  SCPeripheral.h
//  SCBle
//
//  Created by Jianying Wan on 2017/4/13.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//  蓝牙外设自定义类。

#import <CoreBluetooth/CoreBluetooth.h>

@class CBPeripheral;
@interface SCPeripheralObject : NSObject

@property (strong, nonatomic) CBPeripheral *peripheral;         //外设
@property (strong, nonatomic) NSNumber *RSSI;                   //当前外设的RSSI
@property (copy, nonatomic) NSString *aesKey;                   //对应该外设的AES key
@property (copy, nonatomic) NSString *randomValueWithMacAddress;         //外设的信息 随机值(8个字节) + MAC地址(12个字节)

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                            aesKey:(NSString *)aesKey
         randomValueWithMacAddress:(NSString *)randomValueWithMacAddress
                              RSSI:(NSNumber *)RSSI;

@end
