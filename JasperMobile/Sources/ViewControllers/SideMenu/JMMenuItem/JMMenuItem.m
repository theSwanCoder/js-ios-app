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
#import "JMConstants.h"

@implementation JMMenuItem

- (instancetype)initWithItemType:(JMMenuItemType)itemType
{
    self = [super init];
    if (self) {
        _itemType = itemType;
        _itemTitleKey = [self titleKeyWithResourceType];
        _showNotes = NO;
        _selected = NO;
    }
    return self;
}

+ (instancetype)menuItemWithItemType:(JMMenuItemType)itemType
{
    return [[self alloc] initWithItemType:itemType];
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

- (JMMenuItemControllerPresentationStyle)presentationStyle
{
    if (self.itemType == JMMenuItemType_About ||
        self.itemType == JMMenuItemType_Settings) {
        return JMMenuItemControllerPresentationStyle_Modal;
    }
    return JMMenuItemControllerPresentationStyle_Navigate;
}

- (NSString *)itemPageAccessibilityId
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return JMLibraryPageAccessibilityId;
        case JMMenuItemType_SavedItems:
            return JMSavedItemsPageAccessibilityId;
        case JMMenuItemType_Favorites:
            return JMFavoritesPageAccessibilityId;
        case JMMenuItemType_Scheduling:
            return JMSchedulesPageAccessibilityId;
        case JMMenuItemType_Repository:
            return JMRepositoryPageAccessibilityId;
        case JMMenuItemType_About:
            return JMAppAboutPageAccessibilityId;
        case JMMenuItemType_Feedback:
            return JMFeedbackPageAccessibilityId;
        case JMMenuItemType_Settings:
            return JMSettingsPageAccessibilityId;
        case JMMenuItemType_Logout:
            return JMLogoutPageAccessibilityId;
        default:
            return nil;
    }
}

#pragma mark - Private API
- (NSString *) titleKeyWithResourceType
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return @"menuitem_library_label";
        case JMMenuItemType_SavedItems:
            return @"menuitem_saveditems_label";
        case JMMenuItemType_Favorites:
            return @"menuitem_favorites_label";
        case JMMenuItemType_Scheduling:
            return @"menuitem_schedules_label";
        case JMMenuItemType_Repository:
            return @"menuitem_repository_label";
        case JMMenuItemType_About:
            return @"menuitem_about_label";
        case JMMenuItemType_Feedback:
            return @"menuitem_feedback_label";
        case JMMenuItemType_Settings:
            return @"menuitem_settings_label";
        case JMMenuItemType_Logout:
            return @"menuitem_logout_label";
        default:
            return nil;
    }
}

- (UIImage *)iconWithResourceType
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return [UIImage imageNamed:@"ic_library"];
        case JMMenuItemType_Repository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMMenuItemType_SavedItems:
            return [UIImage imageNamed:@"ic_saved_items"];
        case JMMenuItemType_Favorites:
            return [UIImage imageNamed:@"ic_favorites"];
        case JMMenuItemType_Scheduling:
            return [UIImage imageNamed:@"ic_scheduling"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithResourceType
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMMenuItemType_Repository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMMenuItemType_SavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected"];
        case JMMenuItemType_Favorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        case JMMenuItemType_Scheduling:
            return [UIImage imageNamed:@"ic_scheduling_selected"];
        default:
            return nil;
    }
}

- (UIImage *)iconWithNoteWithResourceType
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return [UIImage imageNamed:@"ic_library"];
        case JMMenuItemType_Repository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMMenuItemType_SavedItems:
            return [UIImage imageNamed:@"ic_saved_items_note"];
        case JMMenuItemType_Favorites:
            return [UIImage imageNamed:@"ic_favorites"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithNoteWithResourceType
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMMenuItemType_Repository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMMenuItemType_SavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected_note"];
        case JMMenuItemType_Favorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        default:
            return nil;
    }
}

- (NSString *)nameForAnalytics
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return @"Library";
        case JMMenuItemType_Repository:
            return @"Repository";
        case JMMenuItemType_SavedItems:
            return @"Saved Items";
        case JMMenuItemType_Favorites:
            return @"Favorites";
        case JMMenuItemType_Scheduling:
            return @"Scheduling";
        case JMMenuItemType_About:
            return @"AboutApp";
        case JMMenuItemType_Settings:
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
    return _itemType == otherMenuItem.itemType;
}

- (NSUInteger)hash
{
    return [self.itemTitleKey hash];
}

@end
