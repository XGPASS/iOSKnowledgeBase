//
//  SCBlePeripheralManager.m
//  SCBle
//
//  Created by Jianying Wan on 2017/4/10.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import "SCBlePeripheralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSData+SC_AES.h"
#import "GTMBase64.h"
#import "SCPeripheralObject.h"

///蓝牙设备的开门serviceUUID            //REMAINBLUETOOTH_DOOR 的MD5
NSString * const doorServiceUuid = @"72a2f746-0132-0819-7ba0-f4c73b96597c";

///蓝牙外设的读特征值uuid                //REMAINBLUETOOTH_DOOR_READ  的md5
NSString * const doorReadCharacterUuid = @"96b54186-f57c-ada0-8c00-91ae0ef46a06";

///蓝牙外设的写特征值uuid                //REMAINBLUETOOTH_DOOR_WRITE 的MD5
NSString * const doorWriteCharacterUuid = @"e05cd458-47c7-723e-c799-514fa46e27e9";

@interface SCBlePeripheralManager () <CBPeripheralDelegate>
@property (strong, nonatomic) dispatch_queue_t writeQueue;
@end

@implementation SCBlePeripheralManager {
    CBCharacteristic *_readCharacter;           //读特征值
    CBCharacteristic *_writeCharacter;          //写特征值
    NSString *_peripheralTime;                  //蓝牙外设传回的时间
}

- (instancetype)initWithPeripheral:(SCPeripheralObject *)peripheral {
    if (self = [super init]) {
        _peripheral = peripheral;
        _peripheral.peripheral.delegate = self;
    }
    
    return self;
}


#pragma mark - Lazy Load

- (dispatch_queue_t)writeQueue {
    if (!_writeQueue) {
        _writeQueue = dispatch_queue_create("com.uama.bleWriteQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _writeQueue;
}


#pragma mark - Private Methdods

///拼接开门请求发送的数据
- (NSData *)splitDoorOpenData {

//    if (!_strRandomWithMac) {
//        _strRandomWithMac = @"a3d5e6f4de8ce20c279d";
//    }
//    
    ///加密原文 时间(12字节) + 随机值(8个字节) + MAC地址(12个字节)
    NSString *originalStr = [NSString stringWithFormat:@"%@%@", _peripheralTime, _peripheral.randomValueWithMacAddress];
    NSLog(@"加密原文 --- %@", originalStr);
    //AES ECB加密
    NSData *aesEncryptEcbData = [[originalStr dataUsingEncoding:NSUTF8StringEncoding] SC_AES128ECBEncryptWithKey:_peripheral.aesKey];
    //base64 加密
    NSData *base64Data = [GTMBase64 encodeData:aesEncryptEcbData];
    NSString *strBase64 = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    //定长包头  magicCode:FE version:01  totalLength:包头+包体 cmdid:0001 seq:0001
    NSString *magicCodeWithVersion = @"FE01";
    //16位包头 16位aeskey 变宽包体长度
    NSInteger totalLength = 16 + 16 + base64Data.length;
    NSString *strTotalLength = [NSString stringWithFormat:@"%04ld", (long)totalLength];
    NSString *cmdId = @"0001";
    NSString *seq = @"0001";
    
    ///拼接完整的数据
    NSString *strOpenDoor = [NSString stringWithFormat:@"%@%@%@%@%@%@", magicCodeWithVersion, strTotalLength, cmdId, seq, _peripheral.aesKey, strBase64];
    NSLog(@"strOpenDoor --- %@", strOpenDoor);
    
    return [strOpenDoor dataUsingEncoding:NSUTF8StringEncoding];
}

///向蓝牙外设写数据
- (void)writeData:(NSData *)data {
    NSInteger section = data.length / 20;       //分包发送。
    NSInteger lastSectionLength = data.length % 20;
    if (lastSectionLength > 0) {
        section += 1;
    }
    for (int i=0; i<section; i++) {
        NSData *sectionData;    //分包数据
        if (i == section-1) {
            sectionData = [data subdataWithRange:NSMakeRange(i*20, lastSectionLength)];
        }
        else {
            sectionData = [data subdataWithRange:NSMakeRange(i*20, 20)];
        }
        NSLog(@"sectionStr %@", [[NSString alloc] initWithData:sectionData encoding:NSUTF8StringEncoding]);
        dispatch_async(self.writeQueue, ^{
            if (_writeCharacter) {
                [self.peripheral.peripheral writeValue:sectionData forCharacteristic:_writeCharacter type:CBCharacteristicWriteWithoutResponse];
            }
        });
    }
}


#pragma CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSLog(@"serivces --- %@", peripheral.services);
    
    for (CBService *service in peripheral.services) {
        ///不区分大小写
        if ([service.UUID.UUIDString caseInsensitiveCompare:doorServiceUuid] == NSOrderedSame) {
            ///读取开门服务
            [peripheral discoverCharacteristics:nil forService:service];
            NSLog(@"service find");
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSArray<CBCharacteristic *> *characters = service.characteristics;
    
    ///蓝牙开门服务的特征值
    for (CBCharacteristic *character in characters) {
        if ([character.UUID.UUIDString caseInsensitiveCompare:doorReadCharacterUuid] == NSOrderedSame) {
            //读特征值 监听
            NSLog(@"read get");
            _readCharacter = character;
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }
        else if ([character.UUID.UUIDString caseInsensitiveCompare:doorWriteCharacterUuid] == NSOrderedSame) {
            _writeCharacter = character;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *strValue = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if (strValue.length == 12) {
        //长度为12. 表示第一个包 传输的时间。
        _peripheralTime = strValue;
        NSLog(@"time ---- %@", strValue);
        //发送蓝牙请求
        [self writeData:[self splitDoorOpenData]];
    }
    else if (strValue.length == 1){
        //传回1或者0， 表示开门请求的返回值  0表示成功开门 1表示开门失败
        if ([strValue isEqualToString:@"0"]) {
            NSLog(@"open door success");
            if (_openSuccessBlock) {
                _openSuccessBlock(peripheral);
            }
        }
        else {
            NSLog(@"open door failed");
        }
    }
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"update name --- %@", peripheral.name);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"did read rssi %@", RSSI);
}


@end
