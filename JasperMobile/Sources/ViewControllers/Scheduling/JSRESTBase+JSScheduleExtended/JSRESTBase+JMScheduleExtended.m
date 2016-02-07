//
// Created by Aleksandr Dakhno on 2/6/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JSRESTBase+JMScheduleExtended.h"
#import "JSScheduleResponse.h"
#import "JSScheduleSummary.h"


@implementation JSRESTBase (JMScheduleExtended)

- (void)fetchScheduledJobResourcesWithCompletion:(JSRequestCompletionBlock)completion
{
    NSString *fullURL = [NSString stringWithFormat:@"%@", @"/jobs"];
    JSRequest *request = [[JSRequest alloc] initWithUri:fullURL];
    request.expectedModelClass = [JSScheduleSummary class];
    request.restVersion = JSRESTVersion_2;
    request.method = RKRequestMethodGET;
    request.completionBlock = completion;
    [self sendRequest:request];
}

- (void)fetchScheduledJobResourcesWithResourceURI:(NSString *)resourceURI completion:(JSRequestCompletionBlock)completion
{
    NSString *fullURL = [NSString stringWithFormat:@"%@", @"/jobs"];
    JSRequest *request = [[JSRequest alloc] initWithUri:fullURL];
    request.expectedModelClass = [JSScheduleSummary class];
    request.restVersion = JSRESTVersion_2;
    request.method = RKRequestMethodGET;

    [request addParameter:@"reportUnitURI" withStringValue:resourceURI];

    request.completionBlock = completion;
    [self sendRequest:request];
}

- (void)fetchScheduleMetadataWithId:(NSInteger)scheduleId completion:(JSRequestCompletionBlock)completion
{
    NSString *fullURL = [NSString stringWithFormat:@"%@/%@", @"/jobs", @(scheduleId)];
    JSRequest *request = [[JSRequest alloc] initWithUri:fullURL];
    request.expectedModelClass = [JSScheduleResponse class];
    request.restVersion = JSRESTVersion_2;
    request.method = RKRequestMethodGET;

    request.completionBlock = completion;
    [self sendRequest:request];
}


- (void)updateSchedule:(JSScheduleResponse *)schedule completion:(JSRequestCompletionBlock)completion
{
    NSString *fullURL = [NSString stringWithFormat:@"%@/%@", @"/jobs", @(schedule.jobIdentifier)];
    JSRequest *request = [[JSRequest alloc] initWithUri:fullURL];
    request.expectedModelClass = [JSScheduleResponse class];
    request.body = schedule;
    request.restVersion = JSRESTVersion_2;
    request.method = RKRequestMethodPOST;
    request.completionBlock = completion;
    [self sendRequest:request];
}

@end