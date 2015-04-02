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

- (BOOL) isDashboard
{
    return [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD] || [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY];
}

- (BOOL)isNewDashboard
{
    return [JMUtils isServerVersionUpOrEqual6] && [self.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD];
}

- (JMReport *)reportModelWithVCIdentifier:(NSString *__autoreleasing *)identifier
{
    // TODO: replace seque with constant
    if ([JMUtils isSupportVisualize]) {
        *identifier = @"JMVisualizeReportViewerViewController";
        return [JMVisualizeReport reportWithResource:self inputControls:nil];
    } else {
        *identifier = @"JMReportViewerViewController";
        return [JMRestReport reportWithResource:self inputControls:nil];
    }
}

- (JMDashboard *)dashboardModelWithVCIdentifier:(NSString *__autoreleasing *)identifier
{
    // TODO: replace seque with constant
    if ([self isNewDashboard] && [JMUtils isSupportVisualize]) {
        if ([JMUtils isServerAmber2] && [JMUtils isSystemVersion8]) {
            *identifier = @"JMDashboardVC";
            return [JMVisualizeDashboard dashboardWithResource:self];
        } else {
            *identifier = @"JMVisualizeDashboardViewerVC";
            return [JMVisualizeDashboard dashboardWithResource:self];
        }
    } else {
        *identifier = @"JMDashboardsViewerViewController";
        return [JMDashboard dashboardWithResource:self];
    }
}

- (NSString *)thumbnailImageUrlString
{
    NSString *restURI = [JSConstants sharedInstance].REST_SERVICES_V2_URI;
    NSString *resourceURI = self.uri;
    return  [NSString stringWithFormat:@"%@/%@/thumbnails%@?defaultAllowed=false", self.restClient.serverProfile.serverUrl, restURI, resourceURI];
}

@end
