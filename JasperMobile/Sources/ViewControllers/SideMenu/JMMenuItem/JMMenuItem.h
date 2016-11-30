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

/**
 @author Aleksandr Dakhno odahno@tibco.com
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
