//
//  ViewController.m
//  HealthKitDemo
//
//  Created by yunlong on 2017/6/9.
//  Copyright © 2017年 yunlong. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManager.h"
@interface ViewController ()
//步数
@property(nonatomic,strong) UILabel *stepLabel;

//睡眠
@property(nonatomic,strong) UILabel *sleepLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *stepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stepBtn.frame = CGRectMake(50, 100, 50, 40);
    [stepBtn setTitle:@"步数" forState:UIControlStateNormal];
    [stepBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    stepBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:stepBtn];
    [stepBtn addTarget:self action:@selector(stepBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 100, 200, 40)];
    _stepLabel.backgroundColor = [UIColor greenColor];
    _stepLabel.textAlignment = NSTextAlignmentCenter;
    _stepLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_stepLabel];
    
    UIButton *sleepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sleepBtn.frame = CGRectMake(50, 150, 50, 40);
    [sleepBtn setTitle:@"睡眠" forState:UIControlStateNormal];
    [sleepBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sleepBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:sleepBtn];
    [sleepBtn addTarget:self action:@selector(sleepBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _sleepLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 150, 200, 40)];
    _sleepLabel.backgroundColor = [UIColor greenColor];
    _sleepLabel.textAlignment = NSTextAlignmentCenter;
    _sleepLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_sleepLabel];
}

#pragma mark - 获取步数
- (void)stepBtnClick{
    [[HealthKitManager sharedInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            [[HealthKitManager sharedInstance] getStepCount:^(NSString *stepValue, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _stepLabel.text = [NSString stringWithFormat:@"步数：%@步", stepValue];
                });
            }];
        }else{
            NSLog(@"=======%@", error.domain);
        }
    }];
}

#pragma mark - 获取睡眠
- (void)sleepBtnClick{
    [[HealthKitManager sharedInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            [[HealthKitManager sharedInstance] getSleepCount:^(NSString *sleepValue, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _sleepLabel.text = [NSString stringWithFormat:@"睡眠：%@小时", sleepValue];
                });
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
