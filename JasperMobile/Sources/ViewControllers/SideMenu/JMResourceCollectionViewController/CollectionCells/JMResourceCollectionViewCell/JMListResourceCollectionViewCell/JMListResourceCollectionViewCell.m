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
//  JMListResourceCollectionViewCell.m
//  TIBCO JasperMobile
//

#import "JMListResourceCollectionViewCell.h"
#import "JMResource.h"
#import "JMSavedResources.h"
#import "JMExportResource.h"
#import "JMSavedResources+Helpers.h"

@implementation JMListResourceCollectionViewCell

- (void)setResource:(JMResource *)resource
{
    [super setResource:resource];
    NSString *elementPageAccessibilityId;
    switch (resource.type) {
        case JMResourceTypeFile:
            elementPageAccessibilityId = JMResourceCollectionPageFileResourceListCellAccessibilityId;
            break;
        case JMResourceTypeFolder:
            elementPageAccessibilityId = JMResourceCollectionPageFolderResourceListCellAccessibilityId;
            break;
        case JMResourceTypeReport:
            elementPageAccessibilityId = JMResourceCollectionPageReportResourceListCellAccessibilityId;
            break;
        case JMResourceTypeSchedule:
            elementPageAccessibilityId = JMResourceCollectionPageScheduleResourceListCellAccessibilityId;
            break;
        case JMResourceTypeDashboard:
            elementPageAccessibilityId = JMResourceCollectionPageDashboardResourceListCellAccessibilityId;
            break;
        case JMResourceTypeLegacyDashboard:
            elementPageAccessibilityId = JMResourceCollectionPageLegacyDashboardResourceListCellAccessibilityId;
            break;
        case JMResourceTypeSavedResource: {
            JMSavedResources *savedResource = [JMSavedResources savedReportsFromResource:resource];
            if ([savedResource.format isEqualToString:kJS_CONTENT_TYPE_HTML]) {
                elementPageAccessibilityId = JMResourceCollectionPageHTMLSavedItemsResourceListCellAccessibilityId;
            } else if ([savedResource.format isEqualToString:kJS_CONTENT_TYPE_PDF]) {
                elementPageAccessibilityId = JMResourceCollectionPagePDFSavedItemsResourceListCellAccessibilityId;
            } else if ([savedResource.format isEqualToString:kJS_CONTENT_TYPE_XLS]) {
                elementPageAccessibilityId = JMResourceCollectionPageXLSSavedItemsResourceListCellAccessibilityId;
            }
            break;
        }
        case JMResourceTypeTempExportedReport: {
            JMExportResource *exportedResource = (JMExportResource *)resource;
            if ([exportedResource.format isEqualToString:kJS_CONTENT_TYPE_HTML]) {
                elementPageAccessibilityId = JMResourceCollectionPageHTMLTempExportedResourceListCellAccessibilityId;
            } else if ([exportedResource.format isEqualToString:kJS_CONTENT_TYPE_PDF]) {
                elementPageAccessibilityId = JMResourceCollectionPagePDFTempExportedResourceListCellAccessibilityId;
            } else if ([exportedResource.format isEqualToString:kJS_CONTENT_TYPE_XLS]) {
                elementPageAccessibilityId = JMResourceCollectionPageXLSTempExportedResourceListCellAccessibilityId;
            }
            break;
        }
    }
    [self.backgroundView setAccessibility:YES withTextKey:resource.resourceLookup.label identifier:elementPageAccessibilityId];
}

@end
