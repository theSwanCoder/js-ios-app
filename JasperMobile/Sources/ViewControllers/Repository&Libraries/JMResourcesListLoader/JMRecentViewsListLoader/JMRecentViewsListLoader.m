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
//  JMRecentViewsListLoader.m
//  TIBCO JasperMobile
//

#import "JMRecentViewsListLoader.h"
#import "JMResourceLoaderOption.h"

@implementation JMRecentViewsListLoader
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.accessType = @"viewed";
    }
    return self;
}

- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
//            NSDictionary *optionForSortByAccessTime = @{
//                    kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.accessTime", nil),
//                    kJMResourceListLoaderOptionItemValueKey: @"accessTime"
//            };
//            NSArray *optionsArray = @[optionForSortByAccessTime];
            return @[
                    [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_sortby_accessTime", nil)
                                                      value:@"accessTime"]
            ];
        }
        case JMResourcesListLoaderOptionType_Filter:
            return [super listItemsWithOption:optionType];
    }
}

- (NSInteger)limitOfLoadingResources
{
    return kJMRecentResourcesLimit;
}

@end
