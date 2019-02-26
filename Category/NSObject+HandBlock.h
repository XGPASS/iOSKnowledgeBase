//
//  NSObject+HandBlock.h
//  MDBaseFramework
//
//  Created by jianxing on 16/1/19.
//  Copyright © 2016年 mcdull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  添加点击事件
 */

typedef void(^buttonHandlerBlcok)(id sender);

@interface NSObject (HandBlock)

@property (nonatomic, copy) buttonHandlerBlcok eventHandler;
@property (nonatomic, strong) NSMutableDictionary *evenDict;

- (void)addHandAction:(void(^)(id sender ))handler;

@end
