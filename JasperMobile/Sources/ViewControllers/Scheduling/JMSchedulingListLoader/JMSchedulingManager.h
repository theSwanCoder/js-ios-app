//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMResourcesListLoader.h"

@interface JMSchedulingManager : NSObject
@property (nonatomic, readonly) NSArray *jobs;
- (void)loadJobsWithCompletion:(void (^)(NSArray *jobs, NSError *error))completion;
- (void)jobInfoWithJobIdentifier:(NSInteger)identifier completion:(void (^)(NSDictionary *jobInfo, NSError *error))completion;
- (void)createJobWithData:(NSDictionary *)jobData completion:(void (^)(NSDictionary *job, NSError *error))completion;

- (void)deleteJobWithJobIdentifier:(NSInteger)identifier completion:(void (^)(NSError *error))completion;
@end