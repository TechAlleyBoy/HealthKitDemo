//
//  HealthKitManager.h
//  BJTResearch
//
//  Created by yunlong on 2017/6/9.
//  Copyright © 2017年 yunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthKitManager : NSObject

/**
 * 健康单例
 */
+ (instancetype)sharedInstance;

/**
 * 检查是否支持获取健康数据
 */
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;

/**
 * 获取步数
 */
- (void)getStepCount:(void(^)(NSString *stepValue, NSError *error))completion;

/**
 * 获取睡眠
 */
- (void)getSleepCount:(void(^)(NSString *sleepValue, NSError *error))completion;
    
@end
