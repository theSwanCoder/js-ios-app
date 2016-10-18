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
#import "JMResourceViewerFavoritesHelper.h"
#import "JMResourceViewerMenuHelper.h"

@interface JMResourceViewerStateManager()
@end

@implementation JMResourceViewerStateManager

#pragma mark - Life Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toolbarsHelper = [JMResourceViewerToolbarsHelper new];
        _favoritesHelper = [JMResourceViewerFavoritesHelper new];
        _menuHelper = [JMResourceViewerMenuHelper new];
    }
    return self;
}

#pragma mark - Custom Accessors
- (void)setController:(UIViewController <JMResourceClientHolder, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol, JMResourceViewerProtocol>*)controller
{
    _controller = controller;
    _favoritesHelper.controller = controller;
    _toolbarsHelper.view = (JMBaseResourceView *)controller.view;
    _menuHelper.controller = controller;
    [self setupViews];
}

#pragma mark - Public API

- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState
{
    if (toolbarState == JMResourceViewerToolbarStateTopHidden || toolbarState == JMResourceViewerToolbarStateTopVisible) {
        NSAssert([self.controller respondsToSelector:@selector(topToolbarView)], @"Should be top toolbar view");
    }
    if (toolbarState == JMResourceViewerToolbarStateBottomHidden || toolbarState == JMResourceViewerToolbarStateBottomVisible) {
        NSAssert([self.controller respondsToSelector:@selector(bottomToolbarView)], @"Should be bottom toolbar view");
    }

    [self.toolbarsHelper updatePageForToolbarState:toolbarState];
}

- (void)updatePageForChangingSizeClass
{
    // menu
    if (self.menuHelper.isMenuVisible) {
        [self.menuHelper hideMenu];
        [self.menuHelper showMenuWithAvailableActions:[self availableActions]
                                      disabledActions:[self disabledActions]];
    }

    if (self.needFavoriteButton) {
        [self.favoritesHelper updateAppearence];
    }
}

- (void)updateFavoriteState
{
    [self.favoritesHelper updateFavoriteState];
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
    if ([self.delegate respondsToSelector:@selector(stateManagerWillExit:)]) {
        [self.delegate stateManagerWillExit:self];
    }
}

- (void)backFromNestedView
{
    if ([self.delegate respondsToSelector:@selector(stateManagerWillBackFromNestedResource:)]) {
        [self.delegate stateManagerWillBackFromNestedResource:self];
    }
}

- (void)openDocumentAction
{
    NSAssert(self.openDocumentActionBlock != nil, @"Open Document Action Block is nil");
    self.openDocumentActionBlock();
}

- (void)cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stateManagerWillCancel:)]) {
        [self.delegate stateManagerWillCancel:self];
    }
}

- (void)showMenu
{
    [self.menuHelper showMenuWithAvailableActions:[self availableActions]
                                  disabledActions:[self disabledActions]];
}

#pragma mark - Setup Navigation Items

- (void)initialSetupNavigationItems
{
    [self initialSetupBackButton];
    [self addMenuBarButton];
    [self.favoritesHelper updateAppearence];
}

- (void)setupNavigationItems
{
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
    [self setupBackButtonForNestedResource];
    [self removeMenuBarButton];
    [self.favoritesHelper updateAppearence];

    if (self.openDocumentActionBlock) {
        [self setupOpenDocumentBarButton];
    }
}

- (void)addMenuBarButton
{
    UIBarButtonItem *menuBarButton = [self menuBarButton];
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    [rightBarButtonItems addObject:menuBarButton];
    self.controller.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)removeMenuBarButton
{
    self.controller.navigationItem.rightBarButtonItems = nil;
}

- (void)initialSetupBackButton
{
    UIBarButtonItem *backBarButton = [self defaultBackBarButton];
    self.controller.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)setupBackButtonForNestedResource
{
    UIBarButtonItem *backBarButton = [self backBarButtonForNestedResource];
    self.controller.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)setupOpenDocumentBarButton
{
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

- (UIBarButtonItem *)defaultBackBarButton
{
    NSString *backItemTitle;
    NSArray *viewControllers = self.controller.navigationController.viewControllers;
    NSUInteger index = [viewControllers indexOfObject:self.controller];
    if ((index != NSNotFound) && (viewControllers.count - 1) >= index) {
        UIViewController *previousViewController = viewControllers[index - 1];
        backItemTitle = previousViewController.title;
    } else {
        backItemTitle = JMLocalizedString(@"back_button_title");
    }
    UIBarButtonItem *item = [self backBarButtonWithTitle:backItemTitle
                                                  action:@selector(back)];
    return item;
}

- (UIBarButtonItem *)backBarButtonForNestedResource
{
    UIBarButtonItem *item = [self backBarButtonWithTitle:JMLocalizedString(@"back_button_title")
                                                  action:@selector(backFromNestedView)];
    return item;
}

- (UIBarButtonItem *)backBarButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIBarButtonItem *item;
    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    item = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:title]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:action];
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

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMLocalizedString(@"back_button_title")]) {
        return [self croppedBackButtonTitle:JMLocalizedString(@"back_button_title")];
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

- (UIBarButtonItem *)openDocumentBarButton
{
    UIBarButtonItem *item;
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:self
                                                         action:@selector(openDocumentAction)];
    return item;
}

#pragma mark - Setup Main View

- (void)setupViews
{
    JMBaseResourceView *resourceView = (JMBaseResourceView *)self.controller.view;

    //
    UIView *contentView = [self.controller contentView];
    [resourceView.contentView fillWithView:contentView];
    self.contentView = contentView;

    if ([self.controller respondsToSelector:@selector(topToolbarView)]) {
        UIView *topToolbarView = [self.controller topToolbarView];
        [resourceView.topView fillWithView:topToolbarView];
    }

    if ([self.controller respondsToSelector:@selector(bottomToolbarView)]) {
        UIView *bottomToolbarView = [self.controller bottomToolbarView];
        [resourceView.bottomView fillWithView:bottomToolbarView];
    }

    if ([self.controller respondsToSelector:@selector(nonExistingResourceView)]) {
        UIView *nonExistingResourceView = [self.controller nonExistingResourceView];
        [resourceView.contentView fillWithView:nonExistingResourceView];
        self.nonExistingResourceView = nonExistingResourceView;
    }
}

- (void)showMainView
{
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
                                 cancelBlock:^{
                                     [self cancelAction];
                                 }];
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
    if (self.nonExistingResourceView) {
        self.nonExistingResourceView.hidden = NO;
    }
}

- (void)hideResourceNotExistView
{
    if (self.nonExistingResourceView) {
        self.nonExistingResourceView.hidden = YES;
    }
}


#pragma mark - JMMenuActionsViewProtocol

- (JMMenuActionsViewAction)availableActions
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_None;
    if (![self.favoritesHelper shouldShowFavoriteBarButton] && self.needFavoriteButton) {
        availableAction |= [self favoriteMenuAction];
    }
    availableAction |= [self.controller availableActions];
    return availableAction;
}

- (JMMenuActionsViewAction)disabledActions
{
    JMMenuActionsViewAction disabledActions = JMMenuActionsViewAction_None;
    if ([self.controller respondsToSelector:@selector(disabledActions)]) {
        disabledActions |= [self.controller disabledActions];
    }
    return disabledActions;
}

- (JMMenuActionsViewAction)favoriteMenuAction
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.controller.resource];
    return isResourceInFavorites ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
}

@end
