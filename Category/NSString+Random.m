//
//  NSString+Random.m
//  MDBaseFramework
//
//  Created by jianxing on 16/1/20.
//  Copyright © 2016年 mcdull. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)

+ (NSString *)randomStringLength:(int)length{
    char data[length];
    for (int x=0;x<length;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

@end
