/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSchedule.h"


@implementation JMSchedule

- (instancetype)initWithResourceLookup:(JSResourceLookup *)resourceLookup scheduleLookup:(JSScheduleLookup *)scheduleLookup
{
    self = [super initWithResourceLookup:resourceLookup];
    if (self) {
        _scheduleLookup = scheduleLookup;
    }
    return self;
}

+ (instancetype)scheduleWithResourceLookup:(JSResourceLookup *)resourceLookup scheduleLookup:(JSScheduleLookup *)scheduleLookup
{
    return [[self alloc] initWithResourceLookup:resourceLookup scheduleLookup:scheduleLookup];
}

@end
