/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
#import "JMRecentViews+Helpers.h"
#import "JSResourceLookup+Helpers.h"
#import "JMMainNavigationController.h"

NSString * const kJMShowReportOptionsSegue = @"ShowReportOptions";
NSString * const kJMShowMultiPageReportSegue = @"ShowMultiPageReport";
NSString * const kJMShowDashboardViewerSegue = @"ShowDashboardViewer";
NSString * const kJMShowSavedRecourcesViewerSegue = @"ShowSavedRecourcesViewer";

@interface JMBaseResourceViewerVC () <PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;
@end

@implementation JMBaseResourceViewerVC

@synthesize resourceLookup = _resourceLookup;

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.resourceLookup.label;

    [self setupSubviews];

    // start point of loading resource
    [self startResourceViewing];
    
    // Update count of views for resource
    [JMRecentViews updateCountOfViewsForResourceLookup:self.resourceLookup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Google Analitycs
    self.screenName = NSStringFromClass(self.class);

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

#pragma mark - Handle rotates
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    [self.popoverView animateRotationToNewPoint:point
                                         inView:self.view
                                   withDuration:duration];
    [self setupNavigationItems];
}


#pragma mark - Setups
- (void)setupSubviews
{
    // override in children
}

- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle
{
    // detect backButton text width to truncate with '...'
    NSDictionary *textAttributes = @{NSFontAttributeName : [JMFont navigationBarTitleFont]};
    CGSize titleTextSize = [self.title sizeWithAttributes:textAttributes];
    CGFloat titleTextWidth = ceil(titleTextSize.width);
    CGSize backItemTextSize = [backButtonTitle sizeWithAttributes:textAttributes];
    CGFloat backItemTextWidth = ceil(backItemTextSize.width);
    CGFloat backItemOffset = 12;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    
    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMCustomLocalizedString(@"back.button.title", nil)]) {
        return [self croppedBackButtonTitle:JMCustomLocalizedString(@"back.button.title", nil)];
    }
    return backButtonTitle;
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
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *actionBarButtonItem = [self actionBarButtonItem];
    if (actionBarButtonItem) {
        [items addObject:actionBarButtonItem];
    }

    UIBarButtonItem *favoriteBarButtonItem = [self favoriteBarButtonItem];
    if (favoriteBarButtonItem) {
        [items addObject:favoriteBarButtonItem];
    }
    self.navigationItem.rightBarButtonItems = [items copy];
}

- (void)resetSubViews
{
    // override in children
}


#pragma mark - Resource Viewing
-(void) startResourceViewing
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:[NSString stringWithFormat:@"You need to implement \"%@\" method in \"%@\" class", NSStringFromSelector(_cmd), NSStringFromClass(self.class)] userInfo:nil];
}

- (void) cancelResourceViewingAndExit
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions
- (void) backButtonTapped:(id)sender
{
    [self cancelResourceViewingAndExit];
}

- (void)showAvailableActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    actionsView.availableActions = [self availableActionForResource:self.resourceLookup];
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
    if (sender) {
        [self replaceRightNavigationItem:sender withItem:[self favoriteBarButtonItem]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

- (void)showInfoPage
{
    JMResourceInfoViewController *vc = [NSClassFromString([self.resourceLookup infoVCIdentifier]) new];
    vc.resourceLookup = self.resourceLookup;
    JMMainNavigationController *nextNC = [[JMMainNavigationController alloc] initWithRootViewController:vc];
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

#pragma mark - Helpers

- (UIBarButtonItem *) actionBarButtonItem
{
    if ([self availableActionForResource:self.resourceLookup]) {
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                             target:self
                                                             action:@selector(showAvailableActions)];
    }
    return nil;
}

- (UIBarButtonItem *)infoPageBarButtonItem
{
    UIBarButtonItem *infoPageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_item"]
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(showInfoPage)];
    return infoPageItem;
}

- (UIBarButtonItem *) favoriteBarButtonItem
{
    if (![JMUtils isIphone]) {
        BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resourceLookup];
        NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";

        UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(favoriteButtonTapped:)];
        favoriteItem.tintColor = isResourceInFavorites ? [UIColor yellowColor] : [UIColor whiteColor];
        return favoriteItem;
    }
    return nil;
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    [rightItems replaceObjectAtIndex:index withObject:newItem];
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    if (![self favoriteBarButtonItem]) {
        availableAction |= [JMFavorites isResourceInFavorites:resource] ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
    }
    return availableAction;
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
        UIViewController *previousViewController = [viewControllers objectAtIndex:[viewControllers indexOfObject:self] - 1];
        backItemTitle = previousViewController.title;
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                                                 style:UIBarButtonItemStyleBordered
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
