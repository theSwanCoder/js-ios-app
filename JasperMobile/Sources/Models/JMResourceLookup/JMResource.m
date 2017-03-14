/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResource.h"
#import "JMDashboard.h"
#import "JMLocalization.h"
#import "JMConstants.h"


@implementation JMResource


#pragma mark - Initializers
- (instancetype __nullable)initWithResourceLookup:(JSResourceLookup *__nonnull)resourceLookup
{
    self = [super init];
    if (self) {
        _resourceLookup = resourceLookup;
        _type = [[self class] typeForResourceLookupType:resourceLookup.resourceType];
    }
    return self;
}

+ (instancetype __nullable)resourceWithResourceLookup:(JSResourceLookup *__nonnull)resourceLookup
{
    return [[self alloc] initWithResourceLookup:resourceLookup];
}

#pragma mark - Public API

- (id)modelOfResource
{
    id model;
    switch (self.type) {
        case JMResourceTypeFile: {break;}
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeSavedReport: {break;}
        case JMResourceTypeSavedDashboard: {break;}
        case JMResourceTypeReport: {
            model = [JSReport reportWithResourceLookup:self.resourceLookup];
            break;
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeTempExportedDashboard: {break;}
        case JMResourceTypeDashboard: {
            model = [JMDashboard dashboardWithResource:self];
            break;
        }
        case JMResourceTypeLegacyDashboard: {
            model = [JMDashboard dashboardWithResource:self];
            break;
        }
        case JMResourceTypeSchedule: {break;}
    }
    return model;
}

- (NSString *)localizedResourceType
{
    NSString *localizedResourceType;
    switch (self.type) {
        case JMResourceTypeFile: {
            localizedResourceType = JMLocalizedString(@"resources_type_saved_reportUnit");
            break;
        }
        case JMResourceTypeFolder: {
            localizedResourceType = JMLocalizedString(@"resources_type_folder");
            break;
        }
        case JMResourceTypeSavedReport: {
            localizedResourceType = JMLocalizedString(@"resources_type_saved_reportUnit");
            break;
        }
        case JMResourceTypeSavedDashboard: {
            localizedResourceType = JMLocalizedString(@"resources_type_saved_reportUnit");
            break;
        }
        case JMResourceTypeReport: {
            localizedResourceType = JMLocalizedString(@"resources_type_reportUnit");
            break;
        }
        case JMResourceTypeTempExportedReport: {
            localizedResourceType = JMLocalizedString(@"resources_type_saved_reportUnit");
            break;
        }
        case JMResourceTypeTempExportedDashboard: {
            localizedResourceType = JMLocalizedString(@"resources_type_saved_reportUnit");
            break;
        }
        case JMResourceTypeDashboard: {
            localizedResourceType = JMLocalizedString(@"resources_type_dashboard");
            break;
        }
        case JMResourceTypeLegacyDashboard: {
            localizedResourceType = JMLocalizedString(@"resources_type_dashboard_legacy");
            break;
        }
        case JMResourceTypeSchedule: {
            localizedResourceType = JMLocalizedString(@"resources_type_schedule");
            break;
        }
    }
    return localizedResourceType;
}

- (NSString *)resourceViewerVCIdentifier
{
    NSString *vcIdentifier;
    switch (self.type) {
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeFile:
        case JMResourceTypeSavedReport:
        case JMResourceTypeSavedDashboard:{
            vcIdentifier = @"JMContentResourceViewerVC";
            break;
        }
        case JMResourceTypeReport: {
            vcIdentifier = @"JMReportViewerVC";
            break;
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeTempExportedDashboard: {break;}
        case JMResourceTypeDashboard: {
            vcIdentifier = @"JMDashboardViewerVC";
            break;
        }
        case JMResourceTypeLegacyDashboard: {
            vcIdentifier = @"JMDashboardViewerVC";
            break;
        }
        case JMResourceTypeSchedule: {
            vcIdentifier = @"JMScheduleVC";
            break;
        }
    }
    return vcIdentifier;
}

- (NSString *)infoVCIdentifier
{
    NSString *vcIdentifier = @"JMResourceInfoViewController";
    switch (self.type) {
        case JMResourceTypeFile: {
            vcIdentifier = @"JMRepositoryResourceInfoViewController";
            break;
        }
        case JMResourceTypeFolder: {
            vcIdentifier = @"JMRepositoryResourceInfoViewController";
            break;
        }
        case JMResourceTypeSavedReport:
        case JMResourceTypeSavedDashboard:{
            vcIdentifier = @"JMSavedItemsInfoViewController";
            break;
        }
        case JMResourceTypeReport: {
            vcIdentifier = @"JMReportInfoViewController";
            break;
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeTempExportedDashboard: {break;}
        case JMResourceTypeDashboard: {
            vcIdentifier = @"JMDashboardInfoViewController";
            break;
        }
        case JMResourceTypeLegacyDashboard: {
            vcIdentifier = @"JMDashboardInfoViewController";
            break;
        }
        case JMResourceTypeSchedule: {
            vcIdentifier = @"JMScheduleInfoViewController";
            break;
        }
    }
    return vcIdentifier;
}

#pragma mark - Helpers
+ (JMResourceType)typeForResourceLookupType:(NSString *)resourceLookupType
{
    if ([resourceLookupType isEqualToString:kJS_WS_TYPE_FOLDER]) {
        return JMResourceTypeFolder;
    } else if([resourceLookupType isEqualToString:kJS_WS_TYPE_REPORT_UNIT]) {
        return JMResourceTypeReport;
    } else if([resourceLookupType isEqualToString:kJMSavedReportUnit]) {
        return JMResourceTypeSavedReport;
    } else if([resourceLookupType isEqualToString:kJMTempExportedReportUnit]) {
        return JMResourceTypeTempExportedReport;
    } else if([resourceLookupType isEqualToString:kJMSavedDashboard]) {
        return JMResourceTypeSavedDashboard;
    } else if([resourceLookupType isEqualToString:kJMTempExportedDashboard]) {
        return JMResourceTypeTempExportedDashboard;
    } else if([resourceLookupType isEqualToString:kJS_WS_TYPE_DASHBOARD]) {
        return JMResourceTypeDashboard;
    } else if([resourceLookupType isEqualToString:kJS_WS_TYPE_DASHBOARD_LEGACY]) {
        return JMResourceTypeLegacyDashboard;
    } else if([resourceLookupType isEqualToString:kJS_WS_TYPE_FILE]) {
        return JMResourceTypeFile;
    } else if([resourceLookupType isEqualToString:kJMScheduleUnit]) {
        return JMResourceTypeSchedule;
    }
    return NSNotFound;
}

@end
