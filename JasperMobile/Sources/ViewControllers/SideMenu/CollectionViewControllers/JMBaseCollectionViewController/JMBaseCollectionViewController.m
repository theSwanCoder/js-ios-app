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


//
//  JMBaseCollectionViewController.h
//  TIBCO JasperMobile
//


#import "JMBaseCollectionViewController.h"
#import "SWRevealViewController.h"
#import "JMLoadingCollectionViewCell.h"
#import "JMResourceCollectionViewCell.h"
#import "JMPopupView.h"
#import "PopoverView.h"
#import "JMResourceInfoViewController.h"
#import "JMListOptionsPopupView.h"
#import "JMReportViewerViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMSettingsViewController.h"

#import "JMRepositoryCollectionViewController.h"
#import "JMBaseDashboardViewerVC.h"
#import "JSResourceLookup+Helpers.h"

NSString * const kJMShowFolderContetnSegue = @"ShowFolderContetnSegue";

NSString * const kJMRepresentationTypeDidChangeNotification = @"JMRepresentationTypeDidChangeNotification";

@interface JMBaseCollectionViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, JMPopupViewDelegate, JMResourceCollectionViewCellDelegate, PopoverViewDelegate, JMMenuActionsViewDelegate, JMResourcesListLoaderDelegate>
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
// observers
@property (nonatomic, strong) id deviceOrientationObserver;
@property (nonatomic, strong) id representationTypeObserver;
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, assign) BOOL isScrollToTop;
@end

@implementation JMBaseCollectionViewController
@synthesize representationType = _representationType;


#pragma mark - LifeCycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.deviceOrientationObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.representationTypeObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
    [baseCollectionView setup];
    baseCollectionView.collectionView.delegate = self;
    baseCollectionView.collectionView.dataSource = self;
    
    [baseCollectionView.refreshControl addTarget:self
                                          action:@selector(refershControlAction:)
                                forControlEvents:UIControlEventValueChanged];
    
    baseCollectionView.searchBar.delegate = self;
    
    self.currentOrientation = UIDeviceOrientationUnknown;
        
    [self addObservers];
    [self setupMenu];
    
    self.resourceListLoader.delegate = self;
    self.isScrollToTop = NO;
    
    [self showNavigationItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = NSStringFromClass(self.class);
    
    [self updateIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.resourceListLoader updateIfNeeded];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self isMenuShown]) {
        [self closeMenu];
    }
}

#pragma mark - Custom accessors
- (void)setNeedReloadData:(BOOL)needReloadData
{
    _needReloadData = needReloadData;
    if (self.isViewLoaded && self.view.window && needReloadData) {
        [self updateIfNeeded];
    }
}

- (void)setNeedLayoutUI:(BOOL)needLayoutUI
{
    _needLayoutUI = needLayoutUI;
    _needReloadData = needLayoutUI;
    
    if (self.isViewLoaded && self.view.window && needLayoutUI) {
        [self updateIfNeeded];
    }
}

- (JMResourcesRepresentationType)representationType
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:[self representationTypeKey]]) {
        _representationType = JMResourcesRepresentationTypeFirst();
    } else {
        _representationType = [[NSUserDefaults standardUserDefaults] integerForKey:[self representationTypeKey]];
    }
    return _representationType;
}

- (void)setRepresentationType:(JMResourcesRepresentationType)representationType
{
    if (_representationType != representationType) {
        _representationType = representationType;
        [[NSUserDefaults standardUserDefaults] setInteger:representationType forKey:[self representationTypeKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMRepresentationTypeDidChangeNotification object:nil];
    }
}

- (NSString *)representationTypeKey
{
    if (!_representationTypeKey) {
        _representationTypeKey = [self defaultRepresentationTypeKey];
    }
    return _representationTypeKey;
}

#pragma mark - Actions
- (void)sortByButtonTapped:(id)sender
{
    JMListOptionsPopupView *sortPopup = [[JMListOptionsPopupView alloc] initWithDelegate:self
                                                                                    type:JMPopupViewType_ContentViewOnly
                                                                                   items:[self.resourceListLoader listItemsWithOption:JMResourcesListLoaderOption_Sort]];
    sortPopup.selectedIndex = self.resourceListLoader.sortBySelectedIndex;
    sortPopup.option = JMResourcesListLoaderOption_Sort;
    [sortPopup show];
}

- (void)filterByButtonTapped:(id)sender
{
    JMListOptionsPopupView *filterPopup = [[JMListOptionsPopupView alloc] initWithDelegate:self
                                                                                      type:JMPopupViewType_ContentViewOnly
                                                                                     items:[self.resourceListLoader listItemsWithOption:JMResourcesListLoaderOption_Filter]];
    filterPopup.selectedIndex = self.resourceListLoader.filterBySelectedIndex;
    filterPopup.option = JMResourcesListLoaderOption_Filter;
    [filterPopup show];
}

- (void)refershControlAction:(id)sender
{
    [self.resourceListLoader setNeedsUpdate];
    [self.resourceListLoader updateIfNeeded];
}

- (void)actionButtonClicked:(id) sender
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    actionsView.availableActions = [self availableAction];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);
    
    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
}

- (void)representationTypeButtonTapped:(id)sender
{
    self.representationType = [self nextRepresentationTypeForType:self.representationType];
    [self replaceRightNavigationItem:sender withItem:[self resourceRepresentationItem]];
}

#pragma mark - Private API
- (void)updateIfNeeded
{
    if (self.needReloadData) {
        JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
        [baseCollectionView.collectionView reloadData];
        
        if (self.isScrollToTop) {
            self.isScrollToTop = NO;
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            if ([baseCollectionView.collectionView cellForItemAtIndexPath:firstItemIndexPath]) {
                [baseCollectionView.collectionView scrollToItemAtIndexPath:firstItemIndexPath
                                                          atScrollPosition:UICollectionViewScrollPositionBottom
                                                                  animated:NO];
            }
        }
        
        _needReloadData = NO;
    }
    
    if (self.needLayoutUI) {
        if ([JMUtils isIphone]) {
            [self.popoverView dismiss:YES];
            [self showNavigationItems];
        }
        self.needLayoutUI = NO;
    }
}

#pragma mark - Overloaded methods
- (JMMenuActionsViewAction)availableAction
{
    return JMMenuActionsViewAction_Filter | JMMenuActionsViewAction_Sort;
}

- (NSString *)defaultRepresentationTypeKey
{
    return @"RepresentationTypeKey";
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return [self.resourceListLoader resourceCount];
}

- (JSResourceLookup *)loadedResourceForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resourceListLoader resourceAtIndex:indexPath.row];
}


#pragma mark - Observers
- (void)addObservers
{
    self.deviceOrientationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:@weakselfnotnil(^(NSNotification *notification)) {
                                                                                        if ([self isOrientationChanged]) {
                                                                                            self.needLayoutUI = YES;
                                                                                        }
                                                                                    } @weakselfend];
    
    self.representationTypeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kJMRepresentationTypeDidChangeNotification
                                                                                        object:nil
                                                                                         queue:[NSOperationQueue mainQueue]
                                                                                    usingBlock:@weakselfnotnil(^(NSNotification *notification)) {
                                                                                        self.needReloadData = YES;
                                                                                    } @weakselfend];
}


#pragma mark - Menu setup
- (void)setupMenu
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.menuButton setTarget:revealViewController];
        [self.menuButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

- (void) showNavigationItems
{
    NSMutableArray *navBarItems = [NSMutableArray array];
    JMMenuActionsViewAction availableAction = [self availableAction];
    if (availableAction & JMMenuActionsViewAction_Filter) {
        UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_action"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(filterByButtonTapped:)];
        [navBarItems addObject:filterItem];
    }
    if (availableAction & JMMenuActionsViewAction_Sort) {
        UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort_action"]
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(sortByButtonTapped:)];
        [navBarItems addObject:sortItem];
    }
    
    BOOL shouldConcateItems = ([JMUtils isIphone] && [navBarItems count] > 1) && (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation) ||
                                                                                  (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation) &&
                                                                                   UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)));
    
    if (shouldConcateItems) {
        navBarItems = [NSMutableArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)]];
    }
    [navBarItems addObject:[self resourceRepresentationItem]];
    
    JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
    UIView *searchContainerView = [[UIView alloc] initWithFrame:baseCollectionView.searchBar.bounds];
    searchContainerView.backgroundColor = [UIColor clearColor];
    [searchContainerView addSubview: baseCollectionView.searchBar];
    
    baseCollectionView.searchBar.autoresizingMask = searchContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    baseCollectionView.searchBarPlaceholder.topItem.titleView = searchContainerView;
    self.navigationItem.rightBarButtonItems = navBarItems;
}

#pragma mark - Menu Utils
- (BOOL)isMenuShown
{
    return (self.revealViewController.frontViewPosition == FrontViewPositionRight);
}

- (void)closeMenu
{
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft];
}

#pragma mark - Utils

- (BOOL)isOrientationChanged
{
    BOOL result = NO;
    if ( UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation) ) {
        if (self.currentOrientation != UIDeviceOrientationUnknown) {
            BOOL isOrientationChanged = [UIDevice currentDevice].orientation != self.currentOrientation;
            if (isOrientationChanged) {
                self.currentOrientation = [UIDevice currentDevice].orientation;
                result = YES;
            }
        } else {
            self.currentOrientation = [UIDevice currentDevice].orientation;
            result = YES;
        }
    }
    return result;
}

- (UIBarButtonItem *)resourceRepresentationItem
{
    NSString *imageName = ([self nextRepresentationTypeForType:self.representationType] == JMResourcesRepresentationType_Grid) ? @"grid_button" : @"horizontal_list_button";
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(representationTypeButtonTapped:)];
}

- (JMResourcesRepresentationType)nextRepresentationTypeForType:(JMResourcesRepresentationType)currentType
{
    // last type - grid
    // first type - list
    JMResourcesRepresentationType nextType = (currentType == JMResourcesRepresentationTypeLast()) ? JMResourcesRepresentationTypeFirst() : currentType + 1;
    return nextType;
}

- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self loadedResourceForIndexPath:indexPath];
    id nextVC = nil;
    NSString *controllerIdentifier = nil;

    if ([resourceLookup isReport]) {
        JMReport *report = [resourceLookup reportModelWithVCIdentifier:&controllerIdentifier];
        nextVC = [self.storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
        
        JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
        JMResourceCollectionViewCell *cell = (JMResourceCollectionViewCell *) [baseCollectionView.collectionView cellForItemAtIndexPath:indexPath];
        report.thumbnailImage = cell.thumbnailImage;
        
        [nextVC setReport:report];
    } else if ([resourceLookup isDashboard]) {
        JMDashboard *dashboard = [resourceLookup dashboardModelWithVCIdentifier:&controllerIdentifier];
        nextVC = [self.storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
        [nextVC setDashboard:dashboard];
    } else if ([resourceLookup isFolder]) {
        // TODO: replace seque with constant
        JMRepositoryCollectionViewController *repositoryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMRepositoryCollectionViewController"];
        repositoryViewController.resourceListLoader.resourceLookup = resourceLookup;
        repositoryViewController.navigationItem.leftBarButtonItem = nil;
        repositoryViewController.navigationItem.title = resourceLookup.label;
        repositoryViewController.representationTypeKey = self.representationTypeKey;
        repositoryViewController.representationType = self.representationType;
        nextVC = repositoryViewController;
    }
    if (nextVC) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    [rightItems replaceObjectAtIndex:index withObject:newItem];
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (void)showResourceInfoViewControllerWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    JMResourceInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JMResourceInfoViewController"];
    vc.resourceLookup = resourceLookup;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self numberOfItemsInSection:section];
    if ([self.resourceListLoader hasNextPage]) count++;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
    if (indexPath.item == [self.resourceListLoader resourceCount]) {
        [self.resourceListLoader loadNextPage];
        return [collectionView dequeueReusableCellWithReuseIdentifier:[baseCollectionView loadingCellForRepresentationType:self.representationType] forIndexPath:indexPath];
    }
    
    JMResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[baseCollectionView resourceCellForRepresentationType:self.representationType]
                                                                                   forIndexPath:indexPath];
    cell.resourceLookup = [self loadedResourceForIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMenuShown]) {
        [self closeMenu];
    }
    [self didSelectResourceAtIndexPath:indexPath];
}


#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    
    CGFloat itemHeight = 80.f;
    CGFloat itemWidth = collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    
    if (self.representationType == JMResourcesRepresentationType_Grid) {
        NSInteger countOfCellsInRow = 1;
        while (((countOfCellsInRow * flowLayout.itemSize.width) + (countOfCellsInRow + 1) * flowLayout.minimumInteritemSpacing) < collectionView.frame.size.width) {
            countOfCellsInRow ++;
        }
        countOfCellsInRow --;
        itemHeight = flowLayout.itemSize.height;
        itemWidth = floor((collectionView.frame.size.width - flowLayout.sectionInset.left * (countOfCellsInRow + 1)) / countOfCellsInRow);
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - JMResourceCollectionViewCellDelegate
- (void)infoButtonDidTappedOnCell:(JMResourceCollectionViewCell *)cell
{
    [self showResourceInfoViewControllerWithResourceLookup:cell.resourceLookup];
}


#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_Filter:
            [self filterByButtonTapped:nil];
            break;
        case JMMenuActionsViewAction_Sort:
            [self sortByButtonTapped:nil];
            break;
        default:
            break;
    }
    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newText = searchBar.text;
    if (range.length) {
        // delete symbol
        newText = [newText stringByReplacingCharactersInRange:range withString:@""];
    } else {
        // added new symbol
        newText = [newText stringByAppendingString:text];
    }
    
    [self.resourceListLoader searchWithQuery:newText];
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.resourceListLoader searchWithQuery:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [self.resourceListLoader clearSearchResults];
}

#pragma mark - JMPopupDelegate
- (void)popupViewWillShow:(JMPopupView *)popup
{
    [self.view endEditing:YES];
}

- (void)popupViewValueDidChanged:(JMListOptionsPopupView *)popup
{
    switch (popup.option) {
        case JMResourcesListLoaderOption_Filter: {
            NSUInteger selectedIndex = [popup selectedIndex];
            if (selectedIndex != self.resourceListLoader.filterBySelectedIndex) {
                 self.resourceListLoader.filterBySelectedIndex = selectedIndex;
                [self.resourceListLoader updateIfNeeded];
                
                self.isScrollToTop = YES;
            }
            break;
        }
        case JMResourcesListLoaderOption_Sort: {
            NSUInteger selectedIndex = [popup selectedIndex];
            if (selectedIndex != self.resourceListLoader.sortBySelectedIndex) {
                self.resourceListLoader.sortBySelectedIndex = selectedIndex;
                [self.resourceListLoader updateIfNeeded];
                
                self.isScrollToTop = YES;
            }
            break;
        }
    }
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    [self.popoverView animateRotationToNewPoint:point
                                         inView:self.view
                                   withDuration:duration];
}

#pragma mark - JMResourcesListLoaderDelegate
- (void)resourceListLoaderDidStartLoad:(JMResourcesListLoader *)listLoader
{
    JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
    [baseCollectionView showLoadingView];
}

- (void)resourceListLoaderDidEndLoad:(JMResourcesListLoader *)listLoader withResources:(NSArray *)resources
{
    JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
    [baseCollectionView.refreshControl endRefreshing];
    [baseCollectionView hideLoadingView];
    
    if (resources.count > 0) {
        [baseCollectionView hideNoResultView];
    } else {
        [baseCollectionView showNoResultsView];
    }
    
    self.needReloadData = YES;
}

- (void)resourceListLoaderDidFailed:(JMResourcesListLoader *)listLoader withError:(NSError *)error
{
    JMBaseCollectionView *baseCollectionView = (JMBaseCollectionView *)self.view;
    [baseCollectionView.refreshControl endRefreshing];
    [baseCollectionView hideLoadingView];
    
    [JMUtils showAlertViewWithError:error];
}


@end
