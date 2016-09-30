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
//  JMBaseResourceViewerVC.h
//  TIBCO JasperMobile
//

/**
 @author Olexandr Dahno odahno@tibco.com
 @since 2.1
 */

#import "JMBaseViewController.h"
#import "JMResourceClientHolder.h"
#import "JMMenuActionsView.h"
#import "JMCancelRequestPopup.h"

@class JMBaseResourceViewerVC;
@protocol JMBaseResourceViewerVCDelegate <NSObject>
@optional
- (BOOL)resourceViewer:(JMBaseResourceViewerVC *)resourceViewer shouldCloseViewerAfterDeletingResource:(JMResource *)resource;
- (void)resourceViewer:(JMBaseResourceViewerVC *)resourceViewer didDeleteResource:(JMResource *)resource;

@end

@interface JMBaseResourceViewerVC : JMBaseViewController <JMResourceClientHolder, JMMenuActionsViewDelegate>
@property (nonatomic, weak) id <JMBaseResourceViewerVCDelegate>delegate;

// setup
- (void)setupSubviews;
- (void)addContentView:(UIView *)contentView;
- (void)setupLeftBarButtonItems NS_REQUIRES_SUPER;
- (void)setupRightBarButtonItems NS_REQUIRES_SUPER;
- (void)resetSubViews;

// Working with top toolbar
- (void)addTopToolbar:(UIView *)toolbar;
- (void)removeTopToolbar;
- (void)showTopToolbarAnimated:(BOOL)animated;
- (void)hideTopToolbarAnimated:(BOOL)animated;

// Resource Viewing
- (void) startResourceViewing;
- (void) cancelResourceViewingAndExit:(BOOL)exit NS_REQUIRES_SUPER;

- (JMMenuActionsViewAction)availableAction NS_REQUIRES_SUPER;
- (JMMenuActionsViewAction)disabledAction;

// Loaders
- (void)startShowLoadingIndicators;
- (void)stopShowLoadingIndicators;

- (void)startShowLoaderWithMessage:(NSString *)message;

- (void)startShowLoaderWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock;
- (void)stopShowLoader;

// UIBarButtonItem helpers
- (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target
                                          action:(SEL)action;

- (void) backButtonTapped:(id)sender;
@end
