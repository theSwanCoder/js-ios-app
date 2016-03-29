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
        _showNotes = NO;
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

- (UIImage *)itemIcon
{
    return self.showNotes ? [self iconWithNoteWithResourceType] : [self iconWithResourceType];
}

- (UIImage *)selectedItemIcon
{
    return self.showNotes ? [self selectedIconWithNoteWithResourceType] : [self selectedIconWithResourceType];
}

#pragma mark - Private API
- (NSString *) vcIdentifierForSelectedItem
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return @"JMLibraryNavigationViewController";
        case JMResourceTypeRecentViews:
            return @"JMRecentViewsNavigationViewController";
        case JMResourceTypeSavedItems:
            return @"JMSavedItemsNavigationViewController";
        case JMResourceTypeFavorites:
            return @"JMFavoritesNavigationViewController";
        case JMResourceTypeScheduling:
            return @"JMSchedulingListNC";
        case JMResourceTypeRepository:
            return @"JMRepositoryNavigationViewController";
        case JMResourceTypeAbout:
            return @"JMAboutNavigationViewController";
        default:
            return nil;
    }
}

- (NSString *) titleWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return JMCustomLocalizedString(@"menuitem.library.label", nil);
        case JMResourceTypeRecentViews:
            return JMCustomLocalizedString(@"menuitem.recentviews.label", nil);
        case JMResourceTypeSavedItems:
            return JMCustomLocalizedString(@"menuitem.saveditems.label", nil);
        case JMResourceTypeFavorites:
            return JMCustomLocalizedString(@"menuitem.favorites.label", nil);
        case JMResourceTypeScheduling:
            return JMCustomLocalizedString(@"menuitem.schedules.label", nil);
        case JMResourceTypeRepository:
            return JMCustomLocalizedString(@"menuitem.repository.label", nil);
        case JMResourceTypeAbout:
            return JMCustomLocalizedString(@"menuitem.about.label", nil);
        case JMResourceTypeFeedback:
            return JMCustomLocalizedString(@"menuitem.feedback.label", nil);
        case JMResourceTypeLogout:
            return JMCustomLocalizedString(@"menuitem.logout.label", nil);
        default:
            return nil;
    }
}

- (UIImage *)iconWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library"];
        case JMResourceTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites"];
        case JMResourceTypeScheduling:
            return [UIImage imageNamed:@"ic_scheduling"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMResourceTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views_selected"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        case JMResourceTypeScheduling:
            return [UIImage imageNamed:@"ic_scheduling_selected"];
        default:
            return nil;
    }
}

- (UIImage *)iconWithNoteWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library"];
        case JMResourceTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_note"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithNoteWithResourceType
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMResourceTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views_selected"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected_note"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        default:
            return nil;
    }
}

- (NSString *)nameForAnalytics
{
    switch (self.resourceType) {
        case JMResourceTypeLibrary:
            return @"Library";
        case JMResourceTypeRecentViews:
            return @"Recenlty Viewed";
        case JMResourceTypeRepository:
            return @"Repository";
        case JMResourceTypeSavedItems:
            return @"Saved Items";
        case JMResourceTypeFavorites:
            return @"Favorites";
        case JMResourceTypeScheduling:
            return @"Scheduling";
        case JMResourceTypeAbout:
            return @"AboutApp";
        default:
            return nil;
    }
}

#pragma mark - NSObject
- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    JMMenuItem *otherMenuItem = object;
    return _resourceType == otherMenuItem.resourceType;
}

- (NSUInteger)hash
{
    return [self.itemTitle hash];
}

@end
