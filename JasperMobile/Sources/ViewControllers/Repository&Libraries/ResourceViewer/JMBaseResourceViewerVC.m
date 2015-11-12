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
#import "JSResourceLookup+Helpers.h"
#import "JMMainNavigationController.h"

NSString * const kJMShowReportOptionsSegue = @"ShowReportOptions";
NSString * const kJMShowMultiPageReportSegue = @"ShowMultiPageReport";
NSString * const kJMShowDashboardViewerSegue = @"ShowDashboardViewer";
NSString * const kJMShowSavedRecourcesViewerSegue = @"ShowSavedRecourcesViewer";

@interface JMBaseResourceViewerVC () <PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, assign) BOOL needLayoutUI;
@end

@implementation JMBaseResourceViewerVC

@synthesize resourceLookup = _resourceLookup;

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.resourceLookup.label;

    [self setupSubviews];
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

#pragma mark - Private API
- (void)setNeedLayoutUI:(BOOL)needLayoutUI
{
    _needLayoutUI = needLayoutUI;
    if (self.isViewLoaded && self.view.window && needLayoutUI) {
        [self updateIfNeeded];
    }
}

- (void)updateIfNeeded
{
    if (self.needLayoutUI) {
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
    if ([destinationViewController respondsToSelector:@selector(setResourceLookup:)]) {
        [destinationViewController setResourceLookup:self.resourceLookup];
    }
}

#pragma mark - Custom Accessors
- (void)setResourceRequest:(NSURLRequest *)resourceRequest
{
    if (resourceRequest != _resourceRequest) {
        _resourceRequest = resourceRequest;
    }
}

#pragma mark - Setups
- (void)setupSubviews
{
    // override in children
}

- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle
{
    // detect backButton text width to truncate with '...'
    NSDictionary *textAttributes = @{NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
    CGSize titleTextSize = [self.title sizeWithAttributes:textAttributes];
    CGFloat titleTextWidth = ceilf(titleTextSize.width);
    CGSize backItemTextSize = [backButtonTitle sizeWithAttributes:textAttributes];
    CGFloat backItemTextWidth = ceilf(backItemTextSize.width);
    CGFloat backItemOffset = 12;
    
    CGFloat viewWidth = CGRectGetWidth(self.navigationController.navigationBar.frame);

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMCustomLocalizedString(@"back.button.title", nil)]) {
        return [self croppedBackButtonTitle:JMCustomLocalizedString(@"back.button.title", nil)];
    }
    return backButtonTitle;
}

- (void)resetSubViews
{
    // override in children
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
    NSMutableArray *navBarItems = [NSMutableArray array];
    JMMenuActionsViewAction availableAction = [self availableActionForResource:self.resourceLookup];
    
    if (availableAction && (availableAction ^ [self favoriteAction])) {
        [navBarItems addObject:[self actionBarButtonItem]];
    } else if (![self favoriteItemShouldDisplaySeparately]) {
        [navBarItems addObject:[self favoriteBarButtonItem]];
    }
    
    if ([self favoriteItemShouldDisplaySeparately]) {
        [navBarItems addObject:[self favoriteBarButtonItem]];
    }
    
    self.navigationItem.rightBarButtonItems = [navBarItems copy];
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
    [actionsView setAvailableActions:[self availableActionForResource:self.resourceLookup]
                     disabledActions:[self disabledActionForResource:self.resourceLookup]];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);

    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
}

- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resourceLookup]) {
        [JMFavorites removeFromFavorites:self.resourceLookup];
    } else {
        [JMFavorites addToFavorites:self.resourceLookup];
    }
}

- (void)showInfoPage
{
    JMResourceInfoViewController *vc = (JMResourceInfoViewController *) [NSClassFromString([self.resourceLookup infoVCIdentifier]) new];
    vc.resourceLookup = self.resourceLookup;
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
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resourceLookup];
    NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
    
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(favoriteButtonTapped:)];
    favoriteItem.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
    return favoriteItem;
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    rightItems[index] = newItem;
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    if (![self favoriteItemShouldDisplaySeparately]) {
        availableAction |= [self favoriteAction];
    }
    return availableAction;
}

- (JMMenuActionsViewAction)favoriteAction
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resourceLookup];
    return isResourceInFavorites ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
}

- (JMMenuActionsViewAction)disabledActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction disabledAction = JMMenuActionsViewAction_None;
    return disabledAction;
}

- (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)action
{
    return [self backButtonWithTitle:nil target:target action:action];
}

- (UIBarButtonItem *)backButtonWithTitle:(NSString *)title
                                  target:(id)target
                                  action:(SEL)action
{
    NSString *backItemTitle = title;
    if (!backItemTitle) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIViewController *previousViewController = viewControllers[[viewControllers indexOfObject:self] - 1];
        backItemTitle = previousViewController.title;
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:target
                                                                action:action];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return backItem;
}

#pragma mark - Loader Popups
- (void)startShowLoadingIndicators
{
    [JMUtils showNetworkActivityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopShowLoadingIndicators
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

- (void)startShowLoaderWithMessage:(NSString *)message
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message];
    [self.activityIndicator startAnimating];
}

- (void)startShowLoaderWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message
                                 cancelBlock:cancelBlock];
    [self.activityIndicator startAnimating];
}

- (void)stopShowLoader
{
    [JMUtils hideNetworkActivityIndicator];
    [JMCancelRequestPopup dismiss];
    [self.activityIndicator stopAnimating];
}

@end
