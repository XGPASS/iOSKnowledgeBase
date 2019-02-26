//
//  SCStartUpViewController.m
//  SmartCommunity
//
//  Created by LHP on 14/11/6.
//  Copyright (c) 2014年 UAMA Inc. All rights reserved.
//

#import "SCStartUpViewController.h"
#import "AppDelegate.h"

#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "SCWelcomeURLAPI.h"

@interface SCStartUpViewController ()

@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIImageView *adImageView;

// 当前NSUserDefaults中存储的广告图片URL
@property (strong, nonatomic) NSString *localAdImageUrl;

@end

@implementation SCStartUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CGRect appFrame = [[UIScreen mainScreen] bounds]; //获取
        self.view.frame = appFrame;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
        [self loadImageUrl];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readLocalImageUrl];
    
    UIImage *cachedIamge = [self getCachedAdImage];
    // 存在图片的直接显示
    if (cachedIamge) {
        [self showView];
        [self.adImageView setImage:cachedIamge];
        [UIView animateWithDuration:1 animations:^{
            self.adImageView.alpha = 1.0;
        } completion:nil];
    }else {
        if ([NSString isValid:self.localAdImageUrl]) {
            [self downloadAdImageFromUrl:self.localAdImageUrl];
        }
    }
}

- (void)readLocalImageUrl {
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:kWebAdImageUrl];
    
    if (!object || ![object isKindOfClass:[NSString class]]) {
        return;
    }
    
    self.localAdImageUrl = (NSString *)object;
}

- (void)storeImageUrl:(NSString *)imageUrl {
    if ([NSString isValid:imageUrl]) {
        [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:kWebAdImageUrl];
    }
}

- (UIImage *)getCachedAdImage {
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:kWebAdImageUrl];
    
    if (!object || ![object isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:(NSString *)object];;
}

- (void)downloadAdImageFromUrl:(NSString *)imageUrl {
    if (![NSString isValid:imageUrl]) {
        return;
    }
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (finished && !error) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl toDisk:YES];
        }
    }];
}

- (void)showView {
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
}

- (void)fadeScreen {
    [UIView animateWithDuration:1 animations:^{
       self.view.alpha = 0.0;
    } completion:^(BOOL finished){
        [self finishedFading];
    }];
}

- (void)finishedFading {
    
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)loadImageUrl {
    
    SCWelcomeURLAPI *welcomeAPI = [[SCWelcomeURLAPI alloc] init];
    @weakify(self);
    [welcomeAPI startWithCompletionWithSuccess:^(id responseDataDict) {
        
        @strongify(self);
        NSString *imageUrl = responseDataDict;

        if ([imageUrl isKindOfClass:[NSString class]] && [NSString isValid:imageUrl] && ![imageUrl isEqualToString:self.localAdImageUrl]) {
            self.localAdImageUrl = imageUrl;
            [self storeImageUrl:imageUrl];
            [self downloadAdImageFromUrl:imageUrl];
        }
    } failure:^(NSError *error) {
        [SCAlertHelper handleError:error];
    }];
}

@end
