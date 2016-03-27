/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMResource.h
//  TIBCO JasperMobile
//

#import "JMResource.h"
#import "JMReport.h"
#import "JMDashboard.h"
#import "JMVisualizeDashboard.h"


@implementation JMResource


#pragma mark - Initializers
- (instancetype __nullable)initWithResourceLookup:(JSResourceLookup *__nonnull)resourceLookup
{
    self = [super init];
    if (self) {
        _resourceLookup = resourceLookup;
        _type = [self typeForResourceLookup:resourceLookup];
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
        case JMResourceTypeSavedResource: {break;}
        case JMResourceTypeReport: {
            model = [JMReport reportWithResourceLookup:self.resourceLookup];
            break;
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeDashboard: {
            if ([JMUtils isSupportVisualize]) {
                model = [JMVisualizeDashboard dashboardWithResource:self];
            } else {
                model = [JMDashboard dashboardWithResource:self];
            }
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
            localizedResourceType = JMCustomLocalizedString(@"resources.type.saved.reportUnit", nil);
            break;
        }
        case JMResourceTypeFolder: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.folder", nil);
            break;
        }
        case JMResourceTypeSavedResource: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.saved.reportUnit", nil);
            break;
        }
        case JMResourceTypeReport: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.reportUnit", nil);
            break;
        }
        case JMResourceTypeTempExportedReport: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.saved.reportUnit", nil);
            break;
        }
        case JMResourceTypeDashboard: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.dashboard", nil);
            break;
        }
        case JMResourceTypeLegacyDashboard: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.dashboard.legacy", nil);
            break;
        }
        case JMResourceTypeSchedule: {
            localizedResourceType = JMCustomLocalizedString(@"resources.type.schedule", nil);
            break;
        }
    }
    return localizedResourceType;
}

- (NSString *)resourceViewerVCIdentifier
{
    NSString *vcIdentifier;
    switch (self.type) {
        case JMResourceTypeFile: {break;}
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeSavedResource: {
            vcIdentifier = @"JMSavedResourceViewerViewController";
            break;
        }
        case JMResourceTypeReport: {
            vcIdentifier = @"JMReportViewerVC";
            break;
        }
        case JMResourceTypeTempExportedReport: {break;}
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
            break;
        }
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeSavedResource: {
            vcIdentifier = @"JMSavedItemsInfoViewController";
            break;
        }
        case JMResourceTypeReport: {
            vcIdentifier = @"JMReportInfoViewController";
            break;
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeDashboard: {
            vcIdentifier = @"JMDashboardInfoViewController";
            break;
        }
        case JMResourceTypeLegacyDashboard: {
            vcIdentifier = @"JMDashboardInfoViewController";
            break;
        }
        case JMResourceTypeSchedule: {break;}
    }
    return vcIdentifier;
}

#pragma mark - Helpers
- (JMResourceType)typeForResourceLookup:(JSResourceLookup *)resourceLookup
{
    if ([resourceLookup.resourceType isEqualToString:kJS_WS_TYPE_FOLDER]) {
        return JMResourceTypeFolder;
    } else if([resourceLookup.resourceType isEqualToString:kJS_WS_TYPE_REPORT_UNIT]) {
        return JMResourceTypeReport;
    } else if([resourceLookup.resourceType isEqualToString:kJMSavedReportUnit]) {
        return JMResourceTypeSavedResource;
    } else if([resourceLookup.resourceType isEqualToString:kJMTempExportedReportUnit]) {
        return JMResourceTypeTempExportedReport;
    } else if([resourceLookup.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD]) {
        return JMResourceTypeDashboard;
    } else if([resourceLookup.resourceType isEqualToString:kJS_WS_TYPE_DASHBOARD_LEGACY]) {
        return JMResourceTypeLegacyDashboard;
    } else if([resourceLookup.resourceType isEqualToString:kJS_WS_TYPE_FILE]) {
        return JMResourceTypeFile;
    } else if([resourceLookup.resourceType isEqualToString:kJMScheduleUnit]) {
        return JMResourceTypeSchedule;
    }
}

@end