/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMResourceLoaderOption.m
//  TIBCO JasperMobile
//

#import "JMResourceLoaderOption.h"
#import "JMConstants.h"
#import "JSConstants.h"

@implementation JMResourceLoaderOption

- (instancetype)initWithOptionType:(JMResourceLoaderOptionType)optionType value:(id)value
{
    self = [super init];
    if (self) {
        _elementPageAccessibilityId = [self accessibilityIdentifierForType:optionType];
        _titleKey = [self titleKeyForType:optionType];
        _value = value;
    }
    return self;
}

+ (instancetype)optionWithOptionType:(JMResourceLoaderOptionType)optionType value:(id)value
{
    return [[self alloc] initWithOptionType:optionType value:value];
}

- (instancetype)initWithFormat:(NSString *)format value:(id)value
{
    self = [super init];
    if (self) {
        _elementPageAccessibilityId = [self accessibilityIdentifierForFormat:[format lowercaseString]];
        _titleKey = format;
        _value = value;
    }
    return self;
}

+ (instancetype)optionWithFormat:(NSString *)format value:(id)value
{
    return [[self alloc] initWithFormat:format value:value];
}


- (NSString *)titleKeyForType:(JMResourceLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourceLoaderOptionTypeSortBy_Name:
            return @"resources_sortby_name";
        case JMResourceLoaderOptionTypeSortBy_CreationDate:
            return @"resources_sortby_creationDate";
        case JMResourceLoaderOptionTypeSortBy_ModifiedDate:
            return @"resources_sortby_modifiedDate";
        case JMResourceLoaderOptionTypeSortBy_AccessTime:
            return @"resources_sortby_accessTime";
        case JMResourceLoaderOptionTypeFilterBy_All:
            return @"resources_filterby_type_all";
        case JMResourceLoaderOptionTypeFilterBy_ReportUnit:
            return @"resources_filterby_type_reportUnit";
        case JMResourceLoaderOptionTypeFilterBy_Dashboard:
            return @"resources_filterby_type_dashboard";
        case JMResourceLoaderOptionTypeFilterBy_Folder:
            return @"resources_filterby_type_folder";
        case JMResourceLoaderOptionTypeFilterBy_File:
            return @"resources_filterby_type_files";
        case JMResourceLoaderOptionTypeFilterBy_SavedItem:
            return @"resources_filterby_type_saved_reportUnit";
    }
}

- (NSString *)accessibilityIdentifierForType:(JMResourceLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourceLoaderOptionTypeSortBy_Name:
            return JMResourceLoaderSortByNamePageAccessibilityId;
        case JMResourceLoaderOptionTypeSortBy_CreationDate:
            return JMResourceLoaderSortByCreationDatePageAccessibilityId;
        case JMResourceLoaderOptionTypeSortBy_ModifiedDate:
            return JMResourceLoaderSortByModifiedDatePageAccessibilityId;
        case JMResourceLoaderOptionTypeSortBy_AccessTime:
            return JMResourceLoaderSortByAccessTimePageAccessibilityId;
        case JMResourceLoaderOptionTypeFilterBy_All:
            return JMResourceLoaderFilterByAllPageAccessibilityId;
        case JMResourceLoaderOptionTypeFilterBy_ReportUnit:
            return JMResourceLoaderFilterByReportUnitPageAccessibilityId;
        case JMResourceLoaderOptionTypeFilterBy_Dashboard:
            return JMResourceLoaderFilterByDashboardPageAccessibilityId;
        case JMResourceLoaderOptionTypeFilterBy_Folder:
            return JMResourceLoaderFilterByFolderPageAccessibilityId;
        case JMResourceLoaderOptionTypeFilterBy_File:
            return JMResourceLoaderFilterByFilePageAccessibilityId;
        case JMResourceLoaderOptionTypeFilterBy_SavedItem:
            return JMResourceLoaderFilterBySavedItemPageAccessibilityId;
    }
}

- (NSString *)accessibilityIdentifierForFormat:(NSString *)format
{
    if ([format isEqualToString:kJS_CONTENT_TYPE_HTML]) {
        return JMResourceLoaderFilterByHTMLPageAccessibilityId;
    } else if ([format isEqualToString:kJS_CONTENT_TYPE_PDF]) {
        return JMResourceLoaderFilterByPDFPageAccessibilityId;
    } else if ([format isEqualToString:kJS_CONTENT_TYPE_XLS]) {
        return JMResourceLoaderFilterByXLSPageAccessibilityId;
    }
    return nil;
}

@end
