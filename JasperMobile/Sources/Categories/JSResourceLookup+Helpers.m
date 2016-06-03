//
//  JSResourceLookup+Helpers.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 3/16/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JSResourceLookup+Helpers.h"
#import "JMVisualizeDashboard.h"
#import "JMDashboard.h"
#import "JMReport.h"

@implementation JSResourceLookup (Helpers)

- (BOOL) isFolder
{
    return [self.resourceType isEqualToString:kJS_WS_TYPE_FOLDER];
}

- (BOOL) isReport
{
    return [self.resourceType isEqualToString:kJS_WS_TYPE_REPORT_UNIT];
}

- (BOOL) isSavedReport
{
    return [self.resourceType isEqualToString:kJMSavedReportUnit];
}

- (BOOL) isTempExportedReport
{
    return [self.resourceType isEqualToString:kJMTempExportedReportUnit];
}

- (BOOL) isDashboard
{
    return [self.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD] || [self.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD_LEGACY];
}

- (BOOL) isLegacyDashboard
{
    return [self.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD_LEGACY];
}

- (BOOL)isNewDashboard
{
    return [JMUtils isServerVersionUpOrEqual6] && [self.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD];
}

- (BOOL)isFile
{
    return [self.resourceType isEqualToString:kJS_WS_TYPE_FILE];
}

- (NSString *)resourceViewerVCIdentifier
{
    // TODO: identifiers with constant
    if ([self isReport]) {
        return @"JMReportViewerVC";
    } else if ([self isDashboard]) {
        return @"JMDashboardViewerVC";
    } else if ([self isSavedReport]) {
        return @"JMSavedResourceViewerViewController";
    } else if ([self isFile]) {
        return @"JMSavedResourceViewerViewController";
    }
    return nil;
}

- (NSString *)infoVCIdentifier
{
    if ([self isReport]) {
        return @"JMReportInfoViewController";
    } else if ([self isDashboard]) {
        return @"JMDashboardInfoViewController";
    } else if ([self isSavedReport]) {
        return @"JMSavedItemsInfoViewController";
    }
    return @"JMResourceInfoViewController";
}

- (JMReport *)reportModel
{
    return [JMReport reportWithResourceLookup:self];
}

- (JMDashboard *)dashboardModel
{
    if ([self isNewDashboard] && [JMUtils isSupportVisualize]) {
        return [JMVisualizeDashboard dashboardWithResource:self];
    } else {
        return [JMDashboard dashboardWithResource:self];
    }
}

- (NSString *)localizedResourceType
{
    if ([self.resourceType isEqualToString:kJMSavedReportUnit]) {
        return JMCustomLocalizedString(@"resources_type_saved_reportUnit", nil);
    } else if ([self.resourceType isEqualToString:kJMTempExportedReportUnit]) {
        return JMCustomLocalizedString(@"resources_type_saved_reportUnit", nil);
    } else if ([self.resourceType isEqualToString:kJS_WS_TYPE_REPORT_UNIT]) {
        return JMCustomLocalizedString(@"resources_type_reportUnit", nil);
    } else if ([self.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD]) {
        return JMCustomLocalizedString(@"resources_type_dashboard", nil);
    } else if ([self.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD_LEGACY]) {
        return JMCustomLocalizedString(@"resources_type_dashboard_legacy", nil);
    } else if ([self.resourceType isEqualToString:kJS_WS_TYPE_FOLDER]) {
        return JMCustomLocalizedString(@"resources_type_folder", nil);
    } else if ([self.resourceType isEqualToString:kJS_WS_TYPE_FILE]) {
        return JMCustomLocalizedString(@"resources_type_saved_reportUnit", nil);
    }
    return nil;
}

@end
