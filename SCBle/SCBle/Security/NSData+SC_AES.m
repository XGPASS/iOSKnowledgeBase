//
//  NSData+SC_AES.m
//  SCBle
//
//  Created by Jianying Wan on 2017/4/11.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import "NSData+SC_AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (SC_AES)

///aes128 ecb nopadding encrypt
- (NSData *)SC_AES128ECBEncryptWithKey:(NSString *)key {
    return [self AES128EncryptWithKey:key gIv:@"" padingOption:kCCOptionECBMode];
}

///aes128 ecb nopadding decrypt
- (NSData *)SC_AES128ECBDecryptWithKey:(NSString *)key {
    return [self AES128DecryptWithKey:key gIv:@"" padingOption:kCCOptionECBMode];
}

///aes128 cbc PKCS7Padding encrypt
- (NSData *)SC_AES128CBCEncryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    return [self AES128EncryptWithKey:key gIv:Iv padingOption:kCCOptionPKCS7Padding];
}

///aes128 cbc PKCS7Padding decrypt
- (NSData *)SC_AES128CBCDecryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    return [self AES128DecryptWithKey:key gIv:Iv padingOption:kCCOptionPKCS7Padding];
}

#pragma mark - Private Methods

///AES 128 加密
- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv padingOption:(CCOptions)option {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          option,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

//AES 128 解密
- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv padingOption:(CCOptions)option {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          option,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}


@end
