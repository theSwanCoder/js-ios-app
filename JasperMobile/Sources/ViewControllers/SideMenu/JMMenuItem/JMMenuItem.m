/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMMenuItem.h"
#import "JMLocalization.h"

@implementation JMMenuItem

- (instancetype)initWithItemType:(JMMenuItemType)itemType
{
    self = [super init];
    if (self) {
        _itemType = itemType;
        _itemTitle = [self titleWithResourceType];
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

#pragma mark - Private API
- (NSString *) titleWithResourceType
{
    switch (self.itemType) {
        case JMMenuItemType_Library:
            return JMLocalizedString(@"menuitem_library_label");
        case JMMenuItemType_SavedItems:
            return JMLocalizedString(@"menuitem_saveditems_label");
        case JMMenuItemType_Favorites:
            return JMLocalizedString(@"menuitem_favorites_label");
        case JMMenuItemType_Scheduling:
            return JMLocalizedString(@"menuitem_schedules_label");
        case JMMenuItemType_Repository:
            return JMLocalizedString(@"menuitem_repository_label");
        case JMMenuItemType_About:
            return JMLocalizedString(@"menuitem_about_label");
        case JMMenuItemType_Feedback:
            return JMLocalizedString(@"menuitem_feedback_label");
        case JMMenuItemType_Settings:
            return JMLocalizedString(@"menuitem_settings_label");
        case JMMenuItemType_Logout:
            return JMLocalizedString(@"menuitem_logout_label");
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
    return [self.itemTitle hash];
}

@end
