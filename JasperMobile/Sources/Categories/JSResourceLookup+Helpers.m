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
#import "JMVisualizeReport.h"
#import "JMRestReport.h"

@implementation JSResourceLookup (Helpers)

- (BOOL) isFolder
{
    return [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_FOLDER];
}

- (BOOL) isReport
{
    return [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT];
}

- (BOOL) isSavedReport
{
    return [self.resourceType isEqualToString:kJMSavedReportUnit];
}

- (BOOL) isDashboard
{
    return [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD] || [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY];
}

- (BOOL)isNewDashboard
{
    return [JMUtils isServerVersionUpOrEqual6] && [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD];
}

- (BOOL)isFile
{
    return [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_FILE];
}

- (NSString *)resourceViewerVCIdentifier
{
    // TODO: identifiers with constant
    if ([self isReport]) {
        return @"JMReportViewerVC";
    } else if ([self isDashboard]) {
        return @"JMDashboardViewerVC";
    } else if ([self isSavedReport] || [self isFile]) {
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
    if ([JMUtils isSupportVisualize]) {
        return [JMVisualizeReport reportWithResourceLookup:self];
    } else {
        return [JMRestReport reportWithResourceLookup:self];
    }
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
        return JMCustomLocalizedString(@"resources.type.saved.reportUnit", nil);
    } else if ([self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT]) {
        return JMCustomLocalizedString(@"resources.type.reportUnit", nil);
    } else if ([self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD]) {
        return JMCustomLocalizedString(@"resources.type.dashboard", nil);
    } else if ([self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY]) {
        return JMCustomLocalizedString(@"resources.type.dashboard.legacy", nil);
    } else if ([self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_FOLDER]) {
        return JMCustomLocalizedString(@"resources.type.folder", nil);
    }
    return nil;
}

@end
