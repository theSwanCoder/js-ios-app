/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDashboard.h"
#import "JMDashboardParameter.h"
#import "JMResource.h"
#import "JMUtils.h"

@interface JMDashboard()
// setters
@property (nonatomic, strong, readwrite) JMResource *resource;

@end

@implementation JMDashboard

#pragma mark - LifyCycle
- (void)dealloc
{
    JMLog(@"%@ _ %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)initWithResource:(JMResource *)resource
{
    self = [super initWithResourceLookup:resource.resourceLookup];
    if (self) {
        _resource = resource;
    }
    return self;
}

+ (instancetype)dashboardWithResource:(JMResource *)resourceLookup
{
    return [[self alloc] initWithResource:resourceLookup];
}

@end
