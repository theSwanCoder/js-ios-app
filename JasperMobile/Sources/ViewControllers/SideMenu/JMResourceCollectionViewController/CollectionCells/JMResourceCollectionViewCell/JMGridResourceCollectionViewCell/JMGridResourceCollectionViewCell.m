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
//  JMGridLoadingCollectionViewCell.m
//  TIBCO JasperMobile
//

#import "JMGridResourceCollectionViewCell.h"
#import "NSObject+Additions.h"
#import "JMConstants.h"
#import "JMResource.h"
#import "JMSavedResources.h"
#import "JMExportResource.h"

@implementation JMGridResourceCollectionViewCell

- (void)setResource:(JMResource *)resource
{
    [super setResource:resource];
    NSString *elementPageAccessibilityId;
    switch (resource.type) {
        case JMResourceTypeFile:
            elementPageAccessibilityId = JMResourceCollectionPageFileResourceGridCellAccessibilityId;
            break;
        case JMResourceTypeFolder:
            elementPageAccessibilityId = JMResourceCollectionPageFolderResourceGridCellAccessibilityId;
            break;
        case JMResourceTypeReport:
            elementPageAccessibilityId = JMResourceCollectionPageReportResourceGridCellAccessibilityId;
            break;
        case JMResourceTypeSchedule:
            elementPageAccessibilityId = JMResourceCollectionPageScheduleResourceGridCellAccessibilityId;
            break;
        case JMResourceTypeDashboard:
            elementPageAccessibilityId = JMResourceCollectionPageDashboardResourceGridCellAccessibilityId;
            break;
        case JMResourceTypeLegacyDashboard:
            elementPageAccessibilityId = JMResourceCollectionPageLegacyDashboardResourceGridCellAccessibilityId;
            break;
        case JMResourceTypeSavedResource: {
            JMSavedResources *savedResource = (JMSavedResources *)resource;
            if ([savedResource.format isEqualToString:kJS_CONTENT_TYPE_HTML]) {
                elementPageAccessibilityId = JMResourceCollectionPageHTMLSavedItemsResourceGridCellAccessibilityId;
            } else if ([savedResource.format isEqualToString:kJS_CONTENT_TYPE_PDF]) {
                elementPageAccessibilityId = JMResourceCollectionPagePDFSavedItemsResourceGridCellAccessibilityId;
            } else if ([savedResource.format isEqualToString:kJS_CONTENT_TYPE_XLS]) {
                elementPageAccessibilityId = JMResourceCollectionPageXLSSavedItemsResourceGridCellAccessibilityId;
            }
            break;
        }
        case JMResourceTypeTempExportedReport: {
            JMExportResource *exportedResource = (JMExportResource *)resource;
            if ([exportedResource.format isEqualToString:kJS_CONTENT_TYPE_HTML]) {
                elementPageAccessibilityId = JMResourceCollectionPageHTMLTempExportedResourceGridCellAccessibilityId;
            } else if ([exportedResource.format isEqualToString:kJS_CONTENT_TYPE_PDF]) {
                elementPageAccessibilityId = JMResourceCollectionPagePDFTempExportedResourceGridCellAccessibilityId;
            } else if ([exportedResource.format isEqualToString:kJS_CONTENT_TYPE_XLS]) {
                elementPageAccessibilityId = JMResourceCollectionPageXLSTempExportedResourceGridCellAccessibilityId;
            }
            break;
        }
    }
    [self.backgroundView setAccessibility:YES withTextKey:resource.resourceLookup.label identifier:elementPageAccessibilityId];
}

@end
