/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMRecentViewsListLoader.m
//  TIBCO JasperMobile
//

#import "JMRecentViewsListLoader.h"

@implementation JMRecentViewsListLoader
- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.name", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"label"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.date", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"accessTime"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.countViews", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"popularity"},
                     ];
        case JMResourcesListLoaderOption_Filter:
            return [super listItemsWithOption:option];
    }
}

@end
