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
#import "JMDashboard.h"
#import "JMLocalization.h"
#import "JMConstants.h"
#import "JMAdHoc.h"


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
    switch (self.type) {
        case JMResourceTypeFile: {break;}
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeSavedResource: {break;}
        case JMResourceTypeReport: {
            return [JSReport reportWithResourceLookup:self.resourceLookup];
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeDashboard: {
            return [JMDashboard dashboardWithResource:self];
        }
        case JMResourceTypeLegacyDashboard: {
            return [JMDashboard dashboardWithResource:self];
        }
        case JMResourceTypeSchedule: {break;}
        case JMResourceTypeAdHoc: {
            return [JMAdHoc adHocWithResource:self];
        }
    }
    return nil;
}

- (NSString *)localizedResourceType
{
    switch (self.type) {
        case JMResourceTypeFile: {
            return JMLocalizedString(@"resources_type_saved_reportUnit");
        }
        case JMResourceTypeFolder: {
            return JMLocalizedString(@"resources_type_folder");
        }
        case JMResourceTypeSavedResource: {
            return JMLocalizedString(@"resources_type_saved_reportUnit");
        }
        case JMResourceTypeReport: {
            return JMLocalizedString(@"resources_type_reportUnit");
        }
        case JMResourceTypeTempExportedReport: {
            return JMLocalizedString(@"resources_type_saved_reportUnit");
        }
        case JMResourceTypeDashboard: {
            return JMLocalizedString(@"resources_type_dashboard");
        }
        case JMResourceTypeLegacyDashboard: {
            return JMLocalizedString(@"resources_type_dashboard_legacy");
        }
        case JMResourceTypeSchedule: {
            return JMLocalizedString(@"resources_type_schedule");
        }
        case JMResourceTypeAdHoc: {
            return JMLocalizedString(@"resources_type_adhoc");
        }
    }
    return @"unknown";
}

- (NSString *)resourceViewerVCIdentifier
{
    switch (self.type) {
        case JMResourceTypeFile: {
            return @"JMSavedResourceViewerViewController";
        }
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeSavedResource: {
            return @"JMSavedResourceViewerViewController";
        }
        case JMResourceTypeReport: {
            return @"JMReportViewerVC";
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeDashboard: {
            return @"JMDashboardViewerVC";
        }
        case JMResourceTypeLegacyDashboard: {
            return @"JMDashboardViewerVC";
        }
        case JMResourceTypeSchedule: {
            return @"JMScheduleVC";
        }
        case JMResourceTypeAdHoc: {
            return @"JMAdHocViewerVC";
        }
    }
    return nil;
}

- (NSString *)infoVCIdentifier
{
    switch (self.type) {
        case JMResourceTypeFile: {break;}
        case JMResourceTypeFolder: {break;}
        case JMResourceTypeSavedResource: {
            return @"JMSavedItemsInfoViewController";
        }
        case JMResourceTypeReport: {
            return @"JMReportInfoViewController";
        }
        case JMResourceTypeTempExportedReport: {break;}
        case JMResourceTypeDashboard: {
            return @"JMDashboardInfoViewController";
        }
        case JMResourceTypeLegacyDashboard: {
            return @"JMDashboardInfoViewController";
        }
        case JMResourceTypeSchedule: {
            return @"JMScheduleInfoViewController";
        }
        case JMResourceTypeAdHoc: {
            return @"JMAdHocInfoViewController";}
    }
    return @"JMResourceInfoViewController";
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
    } else if([resourceLookup.resourceType isEqualToString:kJS_WS_TYPE_ADHOC_DATA_VIEW]) {
        return JMResourceTypeAdHoc;
    }
    return NSNotFound;
}

@end
