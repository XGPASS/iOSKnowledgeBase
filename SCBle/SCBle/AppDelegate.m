//
//  AppDelegate.m
//  SCBle
//
//  Created by Jianying Wan on 2017/4/10.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import "AppDelegate.h"
#import "SCBleViewController.h"
#import "NSData+SC_AES.h"
#import "GTMBase64.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    SCBleViewController *bleVc = [[SCBleViewController alloc] initWithNibName:@"SCBleViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:bleVc];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
//    //ecb 加密
//    NSString *str = @"201704071027ABCDEFGHAABBCCDDEEFF";
//    NSString *key = @"REMAIN_BLUETOOTH";
//    NSData *aesEncryptEcbData = [[str dataUsingEncoding:NSUTF8StringEncoding] SC_AES128ECBEncryptWithKey:key];
//    NSData *base64Data = [GTMBase64 encodeData:aesEncryptEcbData];
//    NSString *encryptStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
//    NSLog(@"encryptStr -- %@", encryptStr);
//    NSLog(@"base64Datalength ---- %ld", base64Data.length);
//    NSLog(@"base64Strlength ---- %ld", encryptStr.length);
//    //y4OTn/IEQVocY6nxykIBK9cyGJoRkv/uO7/Pjfnvf0I=
//    
//    //ecb 解密
//    NSData *decodeBase64 = [GTMBase64 decodeString:encryptStr];
//    NSData *aesDecode = [decodeBase64 SC_AES128ECBDecryptWithKey:key];
//    NSString *oriStr = [[NSString alloc] initWithData:aesDecode encoding:NSUTF8StringEncoding];
//    NSLog(@"oriStr --- %@", oriStr);
//    
//    //cbc 加密
//    NSData *aesEncryptCbc = [[str dataUsingEncoding:NSUTF8StringEncoding] SC_AES128CBCEncryptWithKey:key gIv:key];
//    NSString *encryptCBCStr = [[NSString alloc] initWithData:[GTMBase64 encodeData:aesEncryptCbc] encoding:NSUTF8StringEncoding];
//    NSLog(@"encryptStr -- %@", encryptCBCStr);
//    
//    //cbc 解密
//    NSData *decodeBase64CBC = [GTMBase64 decodeString:encryptStr];
//    NSData *aesDecodeCbc = [decodeBase64CBC SC_AES128ECBDecryptWithKey:key];
//    NSString *oriStrCbc = [[NSString alloc] initWithData:aesDecodeCbc encoding:NSUTF8StringEncoding];
//    NSLog(@"oriStrCBC --- %@", oriStrCbc);
    
//    [self writeData:[self splitDoorOpenData]];
    
    return YES;
}

///拼接开门请求发送的数据
- (NSData *)splitDoorOpenData {
    NSString *aesKey = @"REMAIN_BLUETOOTH";
    NSString *strRandomWithMac = @"ABCDEFGHAABBCCDDEEFF";
    
    ///加密原文 时间(12字节) + 随机值(8个字节) + MAC地址(12个字节)
    NSString *originalStr = [NSString stringWithFormat:@"%@%@", @"201704071027", strRandomWithMac];
    //AES ECB加密
    NSData *aesEncryptEcbData = [[originalStr dataUsingEncoding:NSUTF8StringEncoding] SC_AES128ECBEncryptWithKey:aesKey];
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
    NSString *strOpenDoor = [NSString stringWithFormat:@"%@%@%@%@%@%@", magicCodeWithVersion, strTotalLength, cmdId, seq, aesKey, strBase64];
    
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
        NSLog(@"section %d, str --- %@", i, [[NSString alloc] initWithData:sectionData encoding:NSUTF8StringEncoding]);
//        dispatch_async(_writeQueue, ^{
//            if (_writeCharacter) {
//                [self.peripheral writeValue:sectionData forCharacteristic:_writeCharacter type:CBCharacteristicWriteWithoutResponse];
//            }
//        });
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
