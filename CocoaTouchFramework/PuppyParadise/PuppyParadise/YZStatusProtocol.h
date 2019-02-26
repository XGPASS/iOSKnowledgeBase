//
//  YZStatusProtocol.h
//  YZModalStatus
//
//  Created by linyongzhi on 2018/4/25.
//  Copyright © 2018年 linyongzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YZStatusProtocol <NSObject>

- (void)setImage:(UIImage *)image;
- (void)setHeadline:(NSString *)headline;

@end
