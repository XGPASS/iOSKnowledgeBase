//
//  SCBleCenterManager.h
//  SCBle
//
//  Created by Jianying Wan on 2017/4/10.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const KNotificationOpenBleDoor;

@class SCPeripheralObject;
@class CBCentralManager;
@interface SCBleCenterManager : NSObject

@property (strong, nonatomic) NSMutableArray<SCPeripheralObject *> *peripherals;          //蓝牙外设
@property (strong, nonatomic) CBCentralManager *centralManager;                     //蓝牙主体

+ (instancetype)sharedManager;

///开始扫描
- (void)startScanPeripheral;

@end
