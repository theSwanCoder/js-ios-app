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
//  JMResourcesListLoaderOption.h
//  TIBCO JasperMobile
//

/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.5
 */
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JMResourcesListLoaderOptionType) {
    JMResourcesListLoaderOptionType_Filter,
    JMResourcesListLoaderOptionType_Sort
};

@interface JMResourcesListLoaderOption : NSObject
@property (nonatomic, strong, readonly, nonnull) NSString *title;
@property (nonatomic, strong, readonly, nonnull) id value;
@property (nonatomic, assign, readonly) JMResourcesListLoaderOptionType type;

- (nonnull instancetype)initWithType:(JMResourcesListLoaderOptionType)type title:(nonnull NSString *)title value:(nonnull id)value;
+ (nonnull instancetype)optionWithType:(JMResourcesListLoaderOptionType)type title:(nonnull NSString *)title value:(nonnull id)value;
@end
