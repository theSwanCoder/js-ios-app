/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

@import UIKit;

typedef NS_ENUM(NSInteger, JMMenuItemType){
    JMMenuItemType_Library,
    JMMenuItemType_Repository,
    JMMenuItemType_SavedItems,
    JMMenuItemType_Favorites,
    JMMenuItemType_Scheduling,
    JMMenuItemType_About,
    JMMenuItemType_Feedback,
    JMMenuItemType_Settings,
    JMMenuItemType_Logout
};

typedef NS_ENUM(NSInteger, JMMenuItemControllerPresentationStyle){
    JMMenuItemControllerPresentationStyle_Modal,
    JMMenuItemControllerPresentationStyle_Navigate
};


@interface JMMenuItem : NSObject
@property (nonatomic, readonly) JMMenuItemControllerPresentationStyle presentationStyle;
@property (nonatomic, readonly) JMMenuItemType itemType;
@property (nonatomic, readonly) NSString *itemTitle;
@property (nonatomic, readonly) UIImage  *itemIcon;
@property (nonatomic, readonly) UIImage  *selectedItemIcon;

@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL showNotes;

- (instancetype)initWithItemType:(JMMenuItemType)itemType;
+ (instancetype)menuItemWithItemType:(JMMenuItemType)itemType;

- (NSString *) nameForAnalytics;
@end
