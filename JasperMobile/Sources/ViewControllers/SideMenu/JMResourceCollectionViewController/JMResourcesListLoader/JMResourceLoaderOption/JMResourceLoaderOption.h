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
//  JMResourceLoaderOption.h
//  TIBCO JasperMobile
//

/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.5
 */
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, JMResourceLoaderOptionType) {
    JMResourceLoaderOptionTypeSortBy_Name            = 0,
    JMResourceLoaderOptionTypeSortBy_CreationDate,
    JMResourceLoaderOptionTypeSortBy_ModifiedDate,
    JMResourceLoaderOptionTypeSortBy_AccessTime,
    JMResourceLoaderOptionTypeFilterBy_All,
    JMResourceLoaderOptionTypeFilterBy_ReportUnit,
    JMResourceLoaderOptionTypeFilterBy_Dashboard,
    JMResourceLoaderOptionTypeFilterBy_Folder,
    JMResourceLoaderOptionTypeFilterBy_File,
    JMResourceLoaderOptionTypeFilterBy_SavedItem
};

@interface JMResourceLoaderOption : NSObject
@property (nonatomic, strong, readonly) NSString *titleKey;
@property (nonatomic, strong, readonly) NSString *elementPageAccessibilityId;
@property (nonatomic, strong) id value;

- (instancetype)initWithOptionType:(JMResourceLoaderOptionType)optionType value:(id)value;
+ (instancetype)optionWithOptionType:(JMResourceLoaderOptionType)optionType value:(id)value;

- (instancetype)initWithFormat:(NSString *)format value:(id)value;
+ (instancetype)optionWithFormat:(NSString *)format value:(id)value;

@end