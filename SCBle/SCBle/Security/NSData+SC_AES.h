//
//  NSData+SC_AES.h
//  SCBle
//
//  Created by Jianying Wan on 2017/4/11.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SC_AES)



/**
 AES128 加密， ECB模式，无填充

 @param key AES KEY
 @return 加密后的数据
 */
- (NSData *)SC_AES128ECBEncryptWithKey:(NSString *)key;


/**
 AES128 解密， ECB模式，无填充

 @param key AES key
 @return 解密后的数据
 */
- (NSData *)SC_AES128ECBDecryptWithKey:(NSString *)key;

/**
 AES128 加密， CBC模式，填充PKCS7

 @param key AES key
 @param Iv 初始向量
 @return 加密后的数据
 */
- (NSData *)SC_AES128CBCEncryptWithKey:(NSString *)key gIv:(NSString *)Iv;


/**
 AES128 解密， CBC模式，填充PKCS7

 @param key AES key
 @param Iv 初始向量
 @return 解密后的数据
 */
- (NSData *)SC_AES128CBCDecryptWithKey:(NSString *)key gIv:(NSString *)Iv;

@end
