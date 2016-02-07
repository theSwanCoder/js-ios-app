//
// Created by Aleksandr Dakhno on 2/6/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//


@class JSScheduleResponse;

@interface JSRESTBase (JMScheduleExtended)
- (void)fetchScheduledJobResourcesWithCompletion:(JSRequestCompletionBlock)completion;
- (void)fetchScheduledJobResourcesWithResourceURI:(NSString *)resourceURI completion:(JSRequestCompletionBlock)completion;
- (void)fetchScheduleMetadataWithId:(NSInteger)scheduleId completion:(JSRequestCompletionBlock)completion;
- (void)updateSchedule:(JSScheduleResponse *)schedule completion:(JSRequestCompletionBlock)completion;
@end