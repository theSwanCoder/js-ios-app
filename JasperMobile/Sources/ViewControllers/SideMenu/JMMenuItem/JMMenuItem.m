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

- (instancetype)initWithResourceType:(JMResourceType)resourceType
{
    self = [super init];
    if (self) {
        _resourceType = resourceType;
        _itemTitle = [self titleWithResourceType];
        _itemIcon = [self iconWithResourceType];
        _selectedItemIcon = [self selectedIconWithResourceType];
        
        _selected = NO;
    }
    return self;
}

+ (instancetype)menuItemWithResourceType:(JMResourceType)resourceType
{
    return [[[self class] alloc] initWithResourceType:resourceType];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
}

#pragma mark - Private API
- (NSString *) vcIdentifierForSelectedItem
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return @"JMLibraryNavigationViewController";
        case JMResourceTypeSavedItems:
            return @"JMSavedItemsNavigationViewController";
        case JMResourceTypeFavorites:
            return @"JMFavoritesNavigationViewController";
        case JMResourceTypeRepository:
            return @"JMRepositoryNavigationViewController";
        case JMResourceTypeSettings:
            return @"JMSettingsNavigationViewController";
        case JMResourceTypeNone:
            return @"JMSplashViewController";
        default:
            return nil;
    }
}

- (NSString *) titleWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return JMCustomLocalizedString(@"menuitem.library.label", nil);
        case JMResourceTypeSavedItems:
            return JMCustomLocalizedString(@"menuitem.saveditems.label", nil);
        case JMResourceTypeFavorites:
            return JMCustomLocalizedString(@"menuitem.favorites.label", nil);
        case JMResourceTypeRepository:
            return JMCustomLocalizedString(@"menuitem.repository.label", nil);
        case JMResourceTypeSettings:
            return JMCustomLocalizedString(@"menuitem.settings.label", nil);
        case JMResourceTypeLogout:
            return JMCustomLocalizedString(@"menuitem.logout.label", nil);
        case JMResourceTypeNone:
            return @"JMSplashViewController";
        default:
            return nil;
    }
}

- (UIImage *)iconWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites"];
        case JMResourceTypeSettings:
            return [UIImage imageNamed:@"ic_settings"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        case JMResourceTypeSettings:
            return [UIImage imageNamed:@"ic_settings_selected"];
        default:
            return nil;
    }
}

@end