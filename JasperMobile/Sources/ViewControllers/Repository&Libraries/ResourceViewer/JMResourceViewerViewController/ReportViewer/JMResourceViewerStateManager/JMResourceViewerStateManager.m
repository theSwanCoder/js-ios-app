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
//  JMResourceViewerStateManager.m
//  TIBCO JasperMobile
//


#import "JMResourceViewerStateManager.h"
#import "JMResourceClientHolder.h"
#import "JMFavorites+Helpers.h"
#import "JMCancelRequestPopup.h"
#import "JMResourceViewerProtocol.h"
#import "JMBaseResourceView.h"
#import "JMMenuActionsView.h"
#import "PopoverView.h"
#import "UIView+Additions.h"
#import "JMResource.h"
#import "JMReportViewerVC.h"

@interface JMResourceViewerStateManager() <PopoverViewDelegate>
@property (nonatomic, weak) PopoverView *popoverView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *nonExistingResourceView;
@end

@implementation JMResourceViewerStateManager

#pragma mark - Life Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeFavoriteStatus)
                                                     name:kJMFavoritesDidChangedNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Custom Accessors
- (void)setController:(UIViewController <JMResourceClientHolder, JMResourceViewerProtocol, JMMenuActionsViewProtocol, JMMenuActionsViewDelegate> *)controller
{
    _controller = controller;
    [self setupViews];
}

#pragma mark - Notifications
- (void)changeFavoriteStatus
{
    UIBarButtonItem *barButtonItem = [self findFavoriteBarButton];
    [self decorateFavoriteBarButton:barButtonItem];
}

#pragma mark - Public API

- (void)setupPageForState:(JMResourceViewerState)state
{
    self.activeState = state;
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
    switch(state) {
        case JMResourceViewerStateInitial: {
            [self hideTopToolbarAnimated:NO];
            [self hideBottomToolbarAnimated:NO];
        }
        default: {
            break;
        }
    }
}

- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState
{
    switch(toolbarState) {
        case JMResourceViewerToolbarStateTopVisible: {
            [self showTopToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateTopHidden: {
            [self hideTopToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateBottomVisible: {
            [self showBottomToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateBottomHidden: {
            [self hideBottomToolbarAnimated:YES];
            break;
        }
    }
}

- (void)updatePageForChangingSizeClass
{
    // menu
    if (self.popoverView) {
        [self.popoverView dismiss:NO];
        [self showMenu];
    }

    // favorite
    UIBarButtonItem *favoriteButton = [self findFavoriteBarButton];
    if ([self shouldShowFavoriteBarButton]) {
        if (!favoriteButton) {
            [self addFavoriteBarButton];
        }
    } else {
        if (favoriteButton) {
            [self removeFavoriteBarButton:favoriteButton];
        }
    }
}

- (void)reset
{
    // Resource view should have 3 subviews - topView, contentView, bottomView in which could be subviews
    JMBaseResourceView *resourceView = (JMBaseResourceView *)self.controller.view;

    [resourceView.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [resourceView.topView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [resourceView.bottomView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - Actions

- (void)back
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)backFromNestedView
{
    if (self.backFromNestedResourceActionBlock) {
        self.backFromNestedResourceActionBlock();
    }
}

- (void)updateFavoriteState
{
    if ([JMFavorites isResourceInFavorites:self.controller.resource]) {
        [JMFavorites removeFromFavorites:self.controller.resource];
    } else {
        [JMFavorites addToFavorites:self.controller.resource];
    }
}

- (void)showMenu
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self.controller;
    [actionsView setAvailableActions:[self availableActions]
                     disabledActions:[self disabledActions]];
    CGPoint point = CGPointMake(CGRectGetWidth(self.controller.view.frame), -10);

    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.controller.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
    actionsView.popoverView = self.popoverView;
}

- (void)openDocumentAction
{
    NSAssert(self.openDocumentActionBlock != nil, @"Open Document Action Block is nil");
    self.openDocumentActionBlock();
}

#pragma mark - Helpers

- (void)setupNavigationItemForState:(JMResourceViewerState)state
{
    switch (state) {
        case JMResourceViewerStateInitial: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMResourceViewerStateDestroy: {
            break;
        }
        case JMResourceViewerStateLoading: {
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self setupNavigationItems];
            break;
        }
        case JMResourceViewerStateResourceNotExist: {
            break;
        }
        case JMResourceViewerStateNestedResource: {
            [self setupNavigationItemsForNestedResource];
            break;
        }
    }
}

- (void)setupMainViewForState:(JMResourceViewerState)state
{
    [self hideResourceNotExistView];
    switch (state) {
        case JMResourceViewerStateInitial: {
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMResourceViewerStateDestroy: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateLoading: {
            [self showProgress];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self hideProgress];
            [self showMainView];
            break;
        }
        case JMResourceViewerStateResourceNotExist: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self showResourceNotExistView];
            break;
        }
        case JMResourceViewerStateNestedResource: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self hideProgress];
            break;
        }
    }
}

#pragma mark - Setup Navigation Items

- (void)initialSetupNavigationItems
{
    [self initialSetupBackButton];
    [self addMenuBarButton];
    if ([self shouldShowFavoriteBarButton]) {
        [self addFavoriteBarButton];
    }
}

- (void)setupNavigationItems
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if ([self isNavigationItemsForNestedResource]) {
        [self initialSetupNavigationItems];
    }
}

- (BOOL)isNavigationItemsForNestedResource
{
    BOOL isNavigationItemsForNestedResource = NO;

    // TODO: extend this logic
    BOOL isBackButtonForNestedResource = [self isBackButtonForNestedResource];
    if (isBackButtonForNestedResource) {
        isNavigationItemsForNestedResource = YES;
    }

    return isNavigationItemsForNestedResource;
}

- (void)setupNavigationItemsForNestedResource
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self setupBackButtonForNestedResource];
    [self removeMenuBarButton];
    [self removeFavoriteBarButton:[self findFavoriteBarButton]];
    if (self.openDocumentActionBlock) {
        [self setupOpenDocumentBarButton];
    }
}

- (void)addMenuBarButton
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIBarButtonItem *menuBarButton = [self menuBarButton];
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    [rightBarButtonItems addObject:menuBarButton];
    self.controller.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)removeMenuBarButton
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.controller.navigationItem.rightBarButtonItems = nil;
}

- (void)addFavoriteBarButton
{
    UIBarButtonItem *favoriteBarButton = [self favoriteBarButton];
    NSMutableArray *rightBarButtonItems = [self.controller.navigationItem.rightBarButtonItems mutableCopy];
    [rightBarButtonItems addObject:favoriteBarButton];
    self.controller.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)removeFavoriteBarButton:(UIBarButtonItem *)favoriteButton
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (!favoriteButton) {
        return;
    }
    NSMutableArray *rightBarButtonItems = [self.controller.navigationItem.rightBarButtonItems mutableCopy];
    [rightBarButtonItems removeObject:favoriteButton];
    self.controller.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)initialSetupBackButton
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIBarButtonItem *backBarButton = [self backBarButton];
    self.controller.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)setupBackButtonForNestedResource
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIBarButtonItem *backBarButton = [self backBarButtonForNestedResource];
    self.controller.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)setupOpenDocumentBarButton
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIBarButtonItem *openDocumentBarButton = [self openDocumentBarButton];
    self.controller.navigationItem.rightBarButtonItems = @[openDocumentBarButton];
}

- (BOOL)isBackButtonForNestedResource
{
    BOOL isBackButtonForNestedResource = NO;
    if (self.controller.navigationItem.leftBarButtonItem.action == @selector(backFromNestedView)) {
        isBackButtonForNestedResource = YES;
    }
    return isBackButtonForNestedResource;
}

#pragma mark - Navigation Items Helpers

- (UIBarButtonItem *)backBarButton
{
    UIBarButtonItem *item;
    NSString *backItemTitle = self.controller.title;
    if (!backItemTitle) {
        NSArray *viewControllers = self.controller.navigationController.viewControllers;
        NSUInteger index = [viewControllers indexOfObject:self.controller];
        if ((index != NSNotFound) && (viewControllers.count - 1) >= index) {
            UIViewController *previousViewController = viewControllers[index - 1];
            backItemTitle = previousViewController.title;
        } else {
            backItemTitle = JMCustomLocalizedString(@"back_button_title", nil);
        }
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    item = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(back)];
    [item setBackgroundImage:resizebleBackButtonImage
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    return item;
}

- (UIBarButtonItem *)backBarButtonForNestedResource
{
    UIBarButtonItem *item;
    NSString *backItemTitle = JMCustomLocalizedString(@"back_button_title", nil);
    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    item = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backFromNestedView)];
    [item setBackgroundImage:resizebleBackButtonImage
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    return item;
}

- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle
{
    // detect backButton text width to truncate with '...'
    NSDictionary *textAttributes = @{NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
    CGSize titleTextSize = [self.controller.title sizeWithAttributes:textAttributes];
    CGFloat titleTextWidth = ceilf(titleTextSize.width);
    CGSize backItemTextSize = [backButtonTitle sizeWithAttributes:textAttributes];
    CGFloat backItemTextWidth = ceilf(backItemTextSize.width);
    CGFloat backItemOffset = 12;

    CGFloat viewWidth = CGRectGetWidth(self.controller.navigationController.navigationBar.frame);

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMCustomLocalizedString(@"back_button_title", nil)]) {
        return [self croppedBackButtonTitle:JMCustomLocalizedString(@"back_button_title", nil)];
    }
    return backButtonTitle;
}

- (UIBarButtonItem *)menuBarButton
{
    UIBarButtonItem *item;
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:self
                                                         action:@selector(showMenu)];
    return item;
}

- (UIBarButtonItem *)favoriteBarButton
{
    UIBarButtonItem *item;
    item = [[UIBarButtonItem alloc] initWithImage:nil
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(updateFavoriteState)];
    [self decorateFavoriteBarButton:item];
    return item;
}

- (UIBarButtonItem *)openDocumentBarButton
{
    UIBarButtonItem *item;
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:self
                                                         action:@selector(openDocumentAction)];
    return item;
}

- (void)decorateFavoriteBarButton:(UIBarButtonItem *)favoriteButton
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.controller.resource];
    NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
    favoriteButton.image = [UIImage imageNamed:imageName];
    favoriteButton.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
}

- (UIBarButtonItem *)findFavoriteBarButton
{
    UIBarButtonItem *favoriteItem;
    for (UIBarButtonItem *item in self.controller.navigationItem.rightBarButtonItems) {
        if (item.action == @selector(updateFavoriteState)) {
            favoriteItem = item;
            break;
        }
    }
    return favoriteItem;
}

- (BOOL)shouldShowFavoriteBarButton
{
    if (self.activeState == JMResourceViewerStateNestedResource) {
        return NO;
    }

    BOOL shouldShowFavoriteButton = NO;
    BOOL isCompactWidth = [JMUtils isCompactWidth];
    BOOL isRegularWidth = !isCompactWidth;
    BOOL isCompactHeight = [JMUtils isCompactHeight];
    BOOL isRegularHeight = !isCompactHeight;
    if ( (isCompactWidth && isCompactHeight) || (isRegularWidth && isRegularHeight) ) {
        shouldShowFavoriteButton = YES;
    }
    return shouldShowFavoriteButton;
}

#pragma mark - Setup Toolbars

- (void)showTopToolbarAnimated:(BOOL)animated
{
    [self setTopToolbarVisible:YES animated:animated];
}

- (void)hideTopToolbarAnimated:(BOOL)animated
{
    [self setTopToolbarVisible:NO animated:animated];
}

- (void)showBottomToolbarAnimated:(BOOL)animated
{
    [self setBottomToolbarVisible:YES animated:animated];
}

- (void)hideBottomToolbarAnimated:(BOOL)animated
{
    [self setBottomToolbarVisible:NO animated:animated];
}

#pragma mark - Toolbar Helpers
- (void)setTopToolbarVisible:(BOOL)visible animated:(BOOL)animated
{
    JMBaseResourceView *resourceView = (JMBaseResourceView *)self.controller.view;
    resourceView.topViewTopConstraint.constant = visible ? 0 : - CGRectGetHeight(resourceView.topView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.controller.view layoutIfNeeded];
                         }];
    }
}

- (void)setBottomToolbarVisible:(BOOL)visible animated:(BOOL)animated
{
    JMBaseResourceView *resourceView = (JMBaseResourceView *)self.controller.view;
    resourceView.bottomViewBottomConstraint.constant = visible ? 0 : -CGRectGetHeight(resourceView.bottomView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.controller.view layoutIfNeeded];
                         }];
    }
}

#pragma mark - Setup Main View

- (void)setupViews
{
    JMBaseResourceView *resourceView = (JMBaseResourceView *)self.controller.view;

    //
    UIView *contentView = [self.controller contentView];
    [resourceView.contentView fillWithView:contentView];
    self.contentView = contentView;

    //
    UIView *topToolbarView = [self.controller topToolbarView];
    [resourceView.topView fillWithView:topToolbarView];

    //
    UIView *bottomToolbarView = [self.controller bottomToolbarView];
    [resourceView.bottomView fillWithView:bottomToolbarView];

    //
    UIView *nonExistingResourceView = [self.controller nonExistingResourceView];
    [resourceView.contentView fillWithView:nonExistingResourceView];
    self.nonExistingResourceView = nonExistingResourceView;
}

- (void)showMainView
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.contentView.hidden = NO;
}

- (void)hideMainView
{
    self.contentView.hidden = YES;
}

- (void)showProgress
{
    [JMUtils showNetworkActivityIndicator];
    [((JMBaseResourceView *)self.controller.view).activityIndicator startAnimating];
    [JMCancelRequestPopup presentWithMessage:@"status_loading"
                                 cancelBlock:self.cancelOperationBlock];
}

- (void)hideProgress
{
    [JMUtils hideNetworkActivityIndicator];
    [((JMBaseResourceView *)self.controller.view).activityIndicator stopAnimating];
    [JMCancelRequestPopup dismiss];
}

#pragma mark - Setup Resource Not Exist View
- (void)showResourceNotExistView
{
    self.nonExistingResourceView.hidden = NO;
}

- (void)hideResourceNotExistView
{
    self.nonExistingResourceView.hidden = YES;
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

#pragma mark - JMMenuActionsViewProtocol

- (JMMenuActionsViewAction)availableActions
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_None;
    if (![self shouldShowFavoriteBarButton]) {
        availableAction |= [self favoriteAction];
    }
    availableAction |= [self.controller availableActions];
    return availableAction;
}

- (JMMenuActionsViewAction)disabledActions
{
    JMMenuActionsViewAction disabledAction = JMMenuActionsViewAction_None;
    if (self.activeState == JMResourceViewerStateResourceNotExist) {
        disabledAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule | JMMenuActionsViewAction_Print | JMMenuActionsViewAction_ShowExternalDisplay;
    }
    return disabledAction;
}

- (JMMenuActionsViewAction)favoriteAction
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.controller.resource];
    return isResourceInFavorites ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
}

@end