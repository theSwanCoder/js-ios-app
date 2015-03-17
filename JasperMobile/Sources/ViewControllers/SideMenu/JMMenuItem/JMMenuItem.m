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
//  JMMenuItem.h
//  TIBCO JasperMobile
//

#import "JMMenuItem.h"

@implementation JMMenuItem

- (instancetype)initWithTitle:(NSString *)title resourceType:(JMResourceType)resourceType
{
    self = [super init];
    if (self) {
        _title = title;
        _resourceType = resourceType;
        _selected = NO;
    }
    return self;
}

+ (instancetype)menuItemWithTitle:(NSString *)title resourceType:(JMResourceType)resourceType
{
    return [[[self class] alloc] initWithTitle:title resourceType:resourceType];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
}

- (NSString *) vcIdentifierForSelectedItem
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary: {
            return @"JMLibraryNavigationViewController";
            break;
        }
        case JMResourceTypeSavedItems: {
            return @"JMSavedItemsNavigationViewController";
            break;
        }
        case JMResourceTypeFavorites: {
            return @"JMFavoritesNavigationViewController";
            break;
        }
        case JMResourceTypeRepository: {
            return @"JMRepositoryNavigationViewController";
            break;
        }
        case JMResourceTypeSettings: {
            return @"JMSettingsNavigationViewController";
            break;
        }
        case JMResourceTypeNone: {
            return @"JMSplashViewController";
            break;
        }
        default:
            return nil;
    }
}

@end
