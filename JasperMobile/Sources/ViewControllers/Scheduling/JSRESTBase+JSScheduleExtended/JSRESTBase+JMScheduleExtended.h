//
// Created by Aleksandr Dakhno on 2/6/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//


@interface JSRESTBase (JMScheduleExtended)
- (void)fetchScheduledJobResourcesWithResourceURI:(NSString *)resourceURI completion:(JSRequestCompletionBlock)completion;
@end