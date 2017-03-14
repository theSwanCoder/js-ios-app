/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

#import "JMResource.h"

@interface JMSchedule : JMResource
@property (nonatomic, strong) JSScheduleLookup *scheduleLookup;
- (instancetype)initWithResourceLookup:(JSResourceLookup *)resourceLookup scheduleLookup:(JSScheduleLookup *)scheduleLookup;
+ (instancetype)scheduleWithResourceLookup:(JSResourceLookup *)resourceLookup scheduleLookup:(JSScheduleLookup *)scheduleLookup;
@end
