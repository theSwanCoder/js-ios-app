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

#import "JMBaseResourceViewerVC.h"
#import "JMFavorites+Helpers.h"
#import "PopoverView.h"
#import "JMSavedResources+Helpers.h"
#import "JMResourceInfoViewController.h"
#import "JMUtils.h"
#import "JMMainNavigationController.h"
#import "UIViewController+Additions.h"
#import "JMResource.h"
#import "JMBaseResourceView.h"
#import "JMConstants.h"
#import "JMThemesManager.h"

@interface JMBaseResourceViewerVC () <PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, assign) BOOL needLayoutUI;
@end

@implementation JMBaseResourceViewerVC

@synthesize resource = _resource;

#pragma mark - UIViewController LifeCycle
- (void)loadView
{
    JMBaseResourceView *resourceView = [[[NSBundle mainBundle] loadNibNamed:@"JMBaseResourceView" owner:self options:nil] firstObject];
    resourceView.bottomViewBottomConstraint.constant = -CGRectGetHeight(resourceView.bottomView.frame);
    self.view = resourceView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.resource.resourceLookup.label;

    [self hideTopToolbarAnimated:NO];
    [self setupNavigationItems];

    // start point of loading resource
    [self startResourceViewing];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteMarkDidChanged:) name:kJMFavoritesDidChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [self.popoverView dismiss:YES];

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Private API
- (void)setNeedLayoutUI:(BOOL)needLayoutUI
{
    _needLayoutUI = needLayoutUI;
    [self updateIfNeeded];
}

- (void)updateIfNeeded
{
    if (self.needLayoutUI && [self isVisible]) {
        [self setupNavigationItems];
        self.needLayoutUI = NO;
    }
}

- (void)interfaceOrientationDidChanged:(id)notification
{
    self.needLayoutUI = YES;
}

- (void)favoriteMarkDidChanged:(id)notification
{
    self.needLayoutUI = YES;
    [self setupNavigationItems];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    if ([destinationViewController respondsToSelector:@selector(setResource:)]) {
        [destinationViewController setResource:self.resource];
    }
}

#pragma mark - Setups
- (void)setupSubviews
{
    // override in children
}

- (void)addContentView:(UIView *)contentView
{
    [((JMBaseResourceView *)self.view).contentView addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"contentView": contentView}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"contentView": contentView}]];
}

- (void)resetSubViews
{
    // override in children
}

// Working with top toolbar
- (void)addTopToolbar:(UIView *)toolbar
{
    [((JMBaseResourceView *)self.view).topView addSubview:toolbar];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolbar]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"toolbar": toolbar}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[toolbar]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"toolbar": toolbar}]];
}

- (void)removeTopToolbar
{
    [((JMBaseResourceView *) self.view).topView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)showTopToolbarAnimated:(BOOL)animated
{
    ((JMBaseResourceView *)self.view).topViewTopConstraint.constant = 0;
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

- (void)hideTopToolbarAnimated:(BOOL)animated
{
    JMBaseResourceView *resourceView = (JMBaseResourceView *)self.view;
    resourceView.topViewTopConstraint.constant = - CGRectGetHeight(resourceView.topView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

#pragma mark - Setup Navigation Items
- (BOOL) favoriteItemShouldDisplaySeparately
{
    return (![JMUtils isCompactWidth] || ([JMUtils isCompactWidth] && [JMUtils isCompactHeight]));
}

- (void)setupNavigationItems
{
    [self setupRightBarButtonItems];
    [self setupLeftBarButtonItems];
}

- (void)setupLeftBarButtonItems
{
    UIBarButtonItem *backItem = [self backBarButtonItemWithTarget:self
                                                           action:@selector(backButtonTapped:)];

    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)setupRightBarButtonItems
{
    NSMutableArray *navBarItems;
    if (self.navigationItem.rightBarButtonItems.count > 0) {
        navBarItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    } else {
        navBarItems = [NSMutableArray array];
        [navBarItems addObject:[self actionBarButtonItem]];
    }
    
    if ([self favoriteItemShouldDisplaySeparately]) {
        UIBarButtonItem *favoriteItem = [self findFavoriteItem:navBarItems];
        if (!favoriteItem) {
            [navBarItems addObject:[self favoriteBarButtonItem]];
        } else {
            [self changeImageForFavoriteItem:favoriteItem];
        }
    } else {
        // remove favorite item
        UIBarButtonItem *favoriteItem = [self findFavoriteItem:navBarItems];
        if (favoriteItem) {
            [navBarItems removeObject:favoriteItem];
        }
    }
    
    self.navigationItem.rightBarButtonItems = [navBarItems copy];
}

- (UIBarButtonItem *)findFavoriteItem:(NSArray *)navBarItems
{
    UIBarButtonItem *favoriteItem;
    for (UIBarButtonItem *item in navBarItems) {
        if (item.action == @selector(favoriteButtonTapped:)) {
            favoriteItem = item;
            break;
        }
    }
    return favoriteItem;
}

#pragma mark - Resource Viewing
-(void) startResourceViewing
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:[NSString stringWithFormat:@"You need to implement \"%@\" method in \"%@\" class", NSStringFromSelector(_cmd), NSStringFromClass(self.class)] userInfo:nil];
}

- (void) cancelResourceViewingAndExit:(BOOL)exit
{
    if (exit) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions
- (void) backButtonTapped:(id)sender
{
    [self cancelResourceViewingAndExit:YES];
}

- (void)showAvailableActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    [actionsView setAvailableActions:[self availableAction]
                     disabledActions:[self disabledAction]];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);

    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
}

- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resource]) {
        [JMFavorites removeFromFavorites:self.resource];
    } else {
        [JMFavorites addToFavorites:self.resource];
    }
}

- (void)showInfoPage
{
    JMResourceInfoViewController *vc = (JMResourceInfoViewController *) [NSClassFromString([self.resource infoVCIdentifier]) new];
    vc.resource = self.resource;
    JMMainNavigationController *nextNC = [[JMMainNavigationController alloc] initWithRootViewController:vc];

    nextNC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nextNC animated:YES completion:nil];
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_Info:
            [self showInfoPage];
            break;
        case JMMenuActionsViewAction_MakeFavorite:
        case JMMenuActionsViewAction_MakeUnFavorite:
            [self favoriteButtonTapped:nil];
            break;
        default:
            break;
    }

    [self.popoverView dismiss];
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

#pragma mark - Handle rotates
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (self.popoverView) {
        [self.popoverView dismiss:NO];
        [self showAvailableActions];
    }
}

#pragma mark - Helpers

- (UIBarButtonItem *) actionBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:self
                                                         action:@selector(showAvailableActions)];
}

- (UIBarButtonItem *) favoriteBarButtonItem
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resource];
    NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
    
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(favoriteButtonTapped:)];
    favoriteItem.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
    return favoriteItem;
}

- (void)changeImageForFavoriteItem:(UIBarButtonItem *)favoriteItem
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resource];
    NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
    favoriteItem.image = [UIImage imageNamed:imageName];
    favoriteItem.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    rightItems[index] = newItem;
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    if (![self favoriteItemShouldDisplaySeparately]) {
        availableAction |= [self favoriteAction];
    }
    return availableAction;
}

- (JMMenuActionsViewAction)favoriteAction
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resource];
    return isResourceInFavorites ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
}

- (JMMenuActionsViewAction)disabledAction
{
    JMMenuActionsViewAction disabledAction = JMMenuActionsViewAction_None;
    return disabledAction;
}

- (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)action
{
    return [self backButtonWithTitle:nil target:target action:action];
}

#pragma mark - Loader Popups
- (void)startShowLoadingIndicators
{
    [JMUtils showNetworkActivityIndicator];
    [((JMBaseResourceView *)self.view).activityIndicator startAnimating];
}

- (void)stopShowLoadingIndicators
{
    [JMUtils hideNetworkActivityIndicator];
    [((JMBaseResourceView *)self.view).activityIndicator stopAnimating];
}

- (void)startShowLoaderWithMessage:(NSString *)message
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message];
    [((JMBaseResourceView *)self.view).activityIndicator startAnimating];
}

- (void)startShowLoaderWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message
                                 cancelBlock:cancelBlock];
    [((JMBaseResourceView *)self.view).activityIndicator startAnimating];
}

- (void)stopShowLoader
{
    [JMUtils hideNetworkActivityIndicator];
    [JMCancelRequestPopup dismiss];
    [((JMBaseResourceView *)self.view).activityIndicator stopAnimating];
}

@end
