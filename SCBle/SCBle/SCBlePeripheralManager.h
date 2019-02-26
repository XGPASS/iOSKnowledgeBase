//
//  SCBlePeripheralManager.h
//  SCBle
//
//  Created by Jianying Wan on 2017/4/10.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SCPeripheralObject;
@class CBPeripheral;

///蓝牙设备的serviceUUID
extern NSString * const doorServiceUuid;

typedef void(^DoorOpenSuccessBlock)(CBPeripheral *peripheral);          //开门成功回调

@interface SCBlePeripheralManager : NSObject

@property (strong, nonatomic) SCPeripheralObject *peripheral;         //外设对象

@property (copy, nonatomic) DoorOpenSuccessBlock openSuccessBlock;

- (instancetype)initWithPeripheral:(SCPeripheralObject *)peripheral;

- (NSData *)splitDoorOpenData;

@end
