/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMExportResource.h"
#import "JMSavedResources+Helpers.h"

@implementation JMExportResource
- (instancetype)initWithResourceLookup:(JSResourceLookup *)resourceLookup format:(NSString *)format
{
    self = [super initWithResourceLookup:[resourceLookup copy]];
    if (self) {
        self.format = format;
        self.resourceLookup.version = @0;
        self.resourceLookup.permissionMask = @(JSPermissionMask_Administration);
        self.resourceLookup.creationDate = [NSDate date];
        self.resourceLookup.updateDate = [NSDate date];
        self.resourceLookup.uri = [JMSavedResources uriForSavedResourceWithName:resourceLookup.label format:format resourceType:self.type];
        self.type = [self exportResourceTypeForResourceType:self.type];
    }
    return self;
}
    
+ (instancetype)resourceWithResourceLookup:(JSResourceLookup *)resourceLookup format:(NSString *)format
{
    return [[self alloc] initWithResourceLookup:resourceLookup format:format];
}
    
- (JMResourceType)exportResourceTypeForResourceType:(JMResourceType)resourceType
{
    switch (resourceType) {
        case JMResourceTypeReport:
        return JMResourceTypeTempExportedReport;
        case JMResourceTypeDashboard:
        case JMResourceTypeLegacyDashboard:
        return JMResourceTypeTempExportedDashboard;
        default:
        return NSNotFound;
    }
}

@end
