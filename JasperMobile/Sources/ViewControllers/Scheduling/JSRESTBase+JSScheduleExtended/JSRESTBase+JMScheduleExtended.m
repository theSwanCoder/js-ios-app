//
// Created by Aleksandr Dakhno on 2/6/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JSRESTBase+JMScheduleExtended.h"


@implementation JSRESTBase (JMScheduleExtended)

- (void)fetchScheduledJobResourcesWithResourceURI:(NSString *)resourceURI completion:(JSRequestCompletionBlock)completion
{
    NSString *fullURL = [NSString stringWithFormat:@"%@", @"/jobs"];
    JSRequest *request = [[JSRequest alloc] initWithUri:fullURL];
    request.expectedModelClass = [JSScheduleJobResource class];
    request.restVersion = JSRESTVersion_2;
    request.method = RKRequestMethodGET;

    [request addParameter:@"reportUnitURI" withStringValue:resourceURI];

    request.completionBlock = completion;
    [self sendRequest:request];
}

@end