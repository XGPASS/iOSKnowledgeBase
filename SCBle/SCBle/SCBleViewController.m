//
//  SCBleViewController.m
//  SCBle
//
//  Created by Jianying Wan on 2017/4/10.
//  Copyright © 2017年 Jianying Wan. All rights reserved.
//

#import "SCBleViewController.h"
#import "SCBleCenterManager.h"
#import "SCBlePeripheralManager.h"

@interface SCBleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *bleMac;
@end

@implementation SCBleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"蓝牙开门";
    
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
    
    SCBlePeripheralManager *manager = [[SCBlePeripheralManager alloc] init];
    [manager splitDoorOpenData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionOpenBleDoor:) name:KNotificationOpenBleDoor object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionOpenDoor:(id)sender {
    [[SCBleCenterManager sharedManager] startScanPeripheral];
}

- (void)actionOpenBleDoor:(NSNotification *)noti {
    NSString *mac = noti.object;
    _bleMac.text = mac;
}


#pragma mark - Motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motion began");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motion end");
    [[SCBleCenterManager sharedManager] startScanPeripheral];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motion cancel");
}

@end
