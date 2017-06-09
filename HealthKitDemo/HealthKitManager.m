//
//  HealthKitManager.m
//  BJTResearch
//
//  Created by yunlong on 2017/6/9.
//  Copyright © 2017年 yunlong. All rights reserved.
//

#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>
@interface HealthKitManager ()
//HKHealthStore类提供用于访问和存储用户健康数据的界面。
@property (nonatomic, strong) HKHealthStore *healthStore;
@end
@implementation HealthKitManager

#pragma mark - 健康单例
+ (instancetype)sharedInstance {
    static HealthKitManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HealthKitManager alloc] init];
    });
    return instance;
}


#pragma mark - 检查是否支持获取健康数据
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion {
    if (![HKHealthStore isHealthDataAvailable]) {
        NSError *error = [NSError errorWithDomain: @"不支持健康数据" code: 2 userInfo: [NSDictionary dictionaryWithObject:@"HealthKit is not available in th is Device"                                                                      forKey:NSLocalizedDescriptionKey]];
        if (compltion != nil) {
            compltion(NO, error);
        }
        return;
    }else{
        if(self.healthStore == nil){
            self.healthStore = [[HKHealthStore alloc] init];
        }
        //组装需要读写的数据类型
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesRead];
        //注册需要读写的数据类型，也可以在“健康”APP中重新修改
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (compltion != nil) {
                NSLog(@"error->%@", error.localizedDescription);
                compltion (YES, error);
            }
        }];
    }
}

#pragma mark - 写权限
- (NSSet *)dataTypesToWrite{
    //步数
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //身高
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    //体重
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    //活动能量
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    //体温
    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    //睡眠分析
    HKCategoryType *sleepAnalysisType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    return [NSSet setWithObjects:stepCountType,heightType, temperatureType, weightType,activeEnergyType,sleepAnalysisType,nil];
}

#pragma mark - 读权限
- (NSSet *)dataTypesRead{
    //身高
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    //体重
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    //体温
    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    //出生日期
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    //性别
    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    //步数
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //步数+跑步距离
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    //活动能量
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    //睡眠分析
    HKCategoryType *sleepAnalysisType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    return [NSSet setWithObjects:heightType, temperatureType,birthdayType,sexType,weightType,stepCountType, distance, activeEnergyType,sleepAnalysisType,nil];
}

#pragma mark - 获取步数
- (void)getStepCount:(void(^)(NSString *stepValue, NSError *error))completion{
    
    //要检索的数据类型。
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*
     @param         sampleType      要检索的数据类型。
     @param         predicate       数据应该匹配的基准。
     @param         limit           返回的最大数据条数
     @param         sortDescriptors 数据的排序描述
     @param         resultsHandler  结束后返回结果
     */
    HKSampleQuery*query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[HealthKitManager getStepPredicateForSample] limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if(error){
            completion(0,error);
        }else{
            NSLog(@"resultCount = %ld result = %@",results.count,results);
            //把结果装换成字符串类型
            double totleSteps = 0;
            for(HKQuantitySample *quantitySample in results){
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                totleSteps += usersHeight;
            }
            NSLog(@"最新步数：%ld",(long)totleSteps);
            completion([NSString stringWithFormat:@"%ld",(long)totleSteps],error);
        }
    }];
    [self.healthStore executeQuery:query];
}

#pragma mark - 获取睡眠(昨天12点到今天12点)
- (void)getSleepCount:(void(^)(NSString *sleepValue, NSError *error))completion{
    
    //要检索的数据类型。
    HKSampleType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:false];
    
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sleepType predicate:[HealthKitManager getSleepPredicateForSample] limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if (error) {
            NSLog(@"=======%@", error.domain);
        }else{
            NSLog(@"resultCount = %ld result = %@",results.count,results);
            NSInteger totleSleep = 0;
            for (HKCategorySample *sample in results) {//0：卧床时间 1：睡眠时间  2：清醒状态
                NSLog(@"=======%@=======%ld",sample, sample.value);
                if (sample.value == 1) {
                    NSTimeInterval i = [sample.endDate timeIntervalSinceDate:sample.startDate];
                    totleSleep += i;
                }
            }
            NSLog(@"睡眠分析：%.2f",totleSleep/3600.0);
            completion([NSString stringWithFormat:@"%.2f",totleSleep/3600.0],error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}


#pragma mark - 当天时间段
+ (NSPredicate *)getStepPredicateForSample {
    NSDate *now = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *startFormatValue = [NSString stringWithFormat:@"%@000000",[formatter stringFromDate:now]];
    NSString *endFormatValue = [NSString stringWithFormat:@"%@235959",[formatter stringFromDate:now]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * startDate = [formatter dateFromString:startFormatValue];
    NSDate * endDate = [formatter dateFromString:endFormatValue];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

#pragma mark - 昨天12点到今天12点
+ (NSPredicate *)getSleepPredicateForSample {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    //今天12点
    NSDate *now = [NSDate date];
    NSString *endFormatValue = [NSString stringWithFormat:@"%@120000",[formatter stringFromDate:now]];
    
    //昨天12点
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:now];//前一天
    NSString *startFormatValue = [NSString stringWithFormat:@"%@120000",[formatter stringFromDate:lastDay]];
    
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * startDate = [formatter dateFromString:startFormatValue];
    NSDate * endDate = [formatter dateFromString:endFormatValue];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

@end
