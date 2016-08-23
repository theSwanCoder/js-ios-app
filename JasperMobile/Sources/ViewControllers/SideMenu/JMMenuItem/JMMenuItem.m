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
#import "JMLocalization.h"

@implementation JMMenuItem

- (instancetype)initWithSectionType:(JMSectionType)sectionType
{
    self = [super init];
    if (self) {
        _sectionType = sectionType;
        _itemTitle = [self titleWithResourceType];
        _showNotes = NO;
        _selected = NO;
    }
    return self;
}

+ (instancetype)menuItemWithSectionType:(JMSectionType)sectionType
{
    return [[self alloc] initWithSectionType:sectionType];
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
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return @"JMLibraryNavigationViewController";
        case JMSectionTypeRecentViews:
            return @"JMRecentViewsNavigationViewController";
        case JMSectionTypeSavedItems:
            return @"JMSavedItemsNavigationViewController";
        case JMSectionTypeFavorites:
            return @"JMFavoritesNavigationViewController";
        case JMSectionTypeScheduling:
            return @"JMSchedulingListNC";
        case JMSectionTypeRepository:
            return @"JMRepositoryNavigationViewController";
        case JMSectionTypeAbout:
            return @"JMAboutNavigationViewController";
        case JMSectionTypeSettings:
            return @"JMServerOptionsViewController";
        default:
            return nil;
    }
}

- (NSString *) titleWithResourceType
{
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return JMLocalizedString(@"menuitem_library_label");
        case JMSectionTypeRecentViews:
            return JMLocalizedString(@"menuitem_recentviews_label");
        case JMSectionTypeSavedItems:
            return JMLocalizedString(@"menuitem_saveditems_label");
        case JMSectionTypeFavorites:
            return JMLocalizedString(@"menuitem_favorites_label");
        case JMSectionTypeScheduling:
            return JMLocalizedString(@"menuitem_schedules_label");
        case JMSectionTypeRepository:
            return JMLocalizedString(@"menuitem_repository_label");
        case JMSectionTypeAbout:
            return JMLocalizedString(@"menuitem_about_label");
        case JMSectionTypeFeedback:
            return JMLocalizedString(@"menuitem_feedback_label");
        case JMSectionTypeSettings:
            return JMLocalizedString(@"menuitem_settings_label");
        case JMSectionTypeLogout:
            return JMLocalizedString(@"menuitem_logout_label");
        default:
            return nil;
    }
}

- (UIImage *)iconWithResourceType
{
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return [UIImage imageNamed:@"ic_library"];
        case JMSectionTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views"];
        case JMSectionTypeRepository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMSectionTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items"];
        case JMSectionTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites"];
        case JMSectionTypeScheduling:
            return [UIImage imageNamed:@"ic_scheduling"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithResourceType
{
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMSectionTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views_selected"];
        case JMSectionTypeRepository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMSectionTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected"];
        case JMSectionTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        case JMSectionTypeScheduling:
            return [UIImage imageNamed:@"ic_scheduling_selected"];
        default:
            return nil;
    }
}

- (UIImage *)iconWithNoteWithResourceType
{
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return [UIImage imageNamed:@"ic_library"];
        case JMSectionTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views"];
        case JMSectionTypeRepository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMSectionTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_note"];
        case JMSectionTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithNoteWithResourceType
{
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMSectionTypeRecentViews:
            return [UIImage imageNamed:@"ic_recent_views_selected"];
        case JMSectionTypeRepository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMSectionTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected_note"];
        case JMSectionTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        default:
            return nil;
    }
}

- (NSString *)nameForAnalytics
{
    switch (self.sectionType) {
        case JMSectionTypeLibrary:
            return @"Library";
        case JMSectionTypeRecentViews:
            return @"Recenlty Viewed";
        case JMSectionTypeRepository:
            return @"Repository";
        case JMSectionTypeSavedItems:
            return @"Saved Items";
        case JMSectionTypeFavorites:
            return @"Favorites";
        case JMSectionTypeScheduling:
            return @"Scheduling";
        case JMSectionTypeAbout:
            return @"AboutApp";
        case JMSectionTypeSettings:
            return @"Settings";
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
    return _sectionType == otherMenuItem.sectionType;
}

- (NSUInteger)hash
{
    return [self.itemTitle hash];
}

@end
