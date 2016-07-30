/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMResourceViewerStateManager.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.6
*/

#import <UIKit/UIKit.h>
#import "JMResourceViewerToolbarsHelper.h"

@class JMResourceViewerMenuHelper;
@class JMResourceViewerFavoritesHelper;

@protocol JMResourceViewerStateManagerDelegate;
@protocol JMMenuActionsViewDelegate;
@protocol JMResourceClientHolder;
@protocol JMResourceViewerProtocol;
@protocol JMMenuActionsViewProtocol;

@interface JMResourceViewerStateManager : NSObject
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *nonExistingResourceView;
@property (nonatomic, strong) JMResourceViewerToolbarsHelper *toolbarsHelper;
@property (nonatomic, strong) JMResourceViewerFavoritesHelper *favoritesHelper;
@property (nonatomic, assign) BOOL needFavoriteButton;
@property (nonatomic, strong) JMResourceViewerMenuHelper *menuHelper;
@property (nonatomic, copy) void(^openDocumentActionBlock)(void);
@property (nonatomic, weak) UIViewController <JMResourceClientHolder, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol, JMResourceViewerProtocol>*controller;
@property (nonatomic, weak) id <JMResourceViewerStateManagerDelegate> delegate;
- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState;
- (void)updatePageForChangingSizeClass;
- (void)updateFavoriteState;
- (void)reset;
- (void)initialSetupNavigationItems;
- (void)setupNavigationItems;
- (void)setupNavigationItemsForNestedResource;
- (void)removeMenuBarButton;
- (UIBarButtonItem *)backBarButtonWithTitle:(NSString *)title action:(SEL)action;
- (void)showMainView;
- (void)hideMainView;
- (void)showProgress;
- (void)hideProgress;
- (void)showResourceNotExistView;
- (void)hideResourceNotExistView;
@end

@protocol JMResourceViewerStateManagerDelegate <NSObject>
@optional
- (void)stateManagerWillExit:(JMResourceViewerStateManager *)stateManager;
- (void)stateManagerWillCancel:(JMResourceViewerStateManager *)stateManager;
- (void)stateManagerWillBackFromNestedResource:(JMResourceViewerStateManager *)stateManager;
@end