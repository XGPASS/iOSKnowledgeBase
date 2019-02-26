//
//  SCPeripheral.m
//  SCBle
//
//  Created by Jianying Wan on 2017/4/13.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import "SCPeripheralObject.h"

@implementation SCPeripheralObject

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                            aesKey:(NSString *)aesKey
         randomValueWithMacAddress:(NSString *)randomValueWithMacAddress
                              RSSI:(NSNumber *)RSSI {
    if (self = [super init]) {
        _peripheral = peripheral;
        _aesKey = aesKey;
        _aesKey = @"REMAIN_BLUETOOTH";
        _randomValueWithMacAddress = randomValueWithMacAddress;
        _RSSI = RSSI;
    }
    
    return self;
}

@end
