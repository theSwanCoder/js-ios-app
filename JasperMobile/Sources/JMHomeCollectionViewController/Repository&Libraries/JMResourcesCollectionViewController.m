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


#import "JMResourcesCollectionViewController.h"
#import "JMRefreshable.h"
#import "JMResourceCollectionViewCell.h"
#import "JMLoadingCollectionViewCell.h"
#import "UIViewController+fetchInputControls.h"

#import "JMReportViewerViewController.h"
#import "JMReportOptionsViewController.h"
#import "JMSavedResources+Helpers.h"
#import "JMSavedResourcesListLoader.h"

#import "JMSortOptionsPopupView.h"
#import "JMFilterOptionsPopupView.h"
#import "JMResourceInfoViewController.h"
#import "PopoverView.h"

NSString * const kJMShowFolderContetnSegue = @"ShowFolderContetnSegue";

NSString * const kJMRepresentationTypeDidChangedNotification = @"kJMRepresentationTypeDidChangedNotification";


typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationType_HorizontalList = 0,
    JMResourcesRepresentationType_Grid = 1
};

static inline JMResourcesRepresentationType JMResourcesRepresentationTypeFirst() { return JMResourcesRepresentationType_HorizontalList; }
static inline JMResourcesRepresentationType JMResourcesRepresentationTypeLast() { return JMResourcesRepresentationType_Grid; }

@interface JMResourcesCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, JMResourcesListLoaderDelegate, JMPopupViewDelegate, JMResourceCollectionViewCellDelegate, PopoverViewDelegate, JMMenuActionsViewDelegate>


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, weak) IBOutlet UINavigationBar *searchBarPlaceholder;
@property (nonatomic, strong) UISearchBar *searchBar;
// Activity View
@property (nonatomic, weak) IBOutlet UIView *activityView;
@property (nonatomic, weak) IBOutlet UILabel *activityViewTitleLabel;
// noResults view
@property (nonatomic, weak) IBOutlet UILabel *noResultsViewTitleLabel;

@property (nonatomic, strong) JMResourcesListLoader *resourceListLoader;

@property (nonatomic, assign) BOOL needReloadData;

@property (nonatomic, assign) BOOL needLayoutUI;

@property (nonatomic, assign) JMResourcesRepresentationType representationType;

@property (nonatomic, strong) PopoverView *popoverView;

@end

@implementation JMResourcesCollectionViewController
@dynamic representationType;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];
    
    if (self.resourceListLoader.resourceLookup) {
        self.title = self.resourceListLoader.resourceLookup.label;
    }
    
    self.activityViewTitleLabel.text = JMCustomLocalizedString(@"detail.resourcesloading.msg", nil);
    self.noResultsViewTitleLabel.text = JMCustomLocalizedString(@"detail.noresults.msg", nil);
    
    self.activityViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    self.noResultsViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    
    for (NSInteger i = JMResourcesRepresentationTypeFirst(); i <= JMResourcesRepresentationTypeLast(); i ++) {
        [self.collectionView registerNib:[UINib nibWithNibName:[self resourceCellForRepresentationType:i] bundle:nil] forCellWithReuseIdentifier:[self resourceCellForRepresentationType:i]];
        [self.collectionView registerNib:[UINib nibWithNibName:[self loadingCellForRepresentationType:i] bundle:nil] forCellWithReuseIdentifier:[self loadingCellForRepresentationType:i]];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refershControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self showNavigationItems];
    [self.resourceListLoader updateIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakselfnotnil(^(NSNotification *notification)) {
        self.needLayoutUI = YES;
    } @weakselfend];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kJMRepresentationTypeDidChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakselfnotnil(^(NSNotification *notification)) {
        self.needReloadData = YES;
    } @weakselfend];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.resourceListLoader updateIfNeeded];
}

- (JMResourcesRepresentationType)representationType
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:[self getRepresentationTypeKey]]) {
        self.representationType = JMResourcesRepresentationTypeFirst();
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:[self getRepresentationTypeKey]];
}

- (void)setRepresentationType:(JMResourcesRepresentationType)representationType
{
    BOOL representationTypeAlreadyExist = [[NSUserDefaults standardUserDefaults] objectForKey:[self getRepresentationTypeKey]] ? YES : NO;
    if (!representationTypeAlreadyExist || (representationTypeAlreadyExist && self.representationType != representationType)) {
        [[NSUserDefaults standardUserDefaults] setInteger:representationType forKey:[self getRepresentationTypeKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMRepresentationTypeDidChangedNotification object:nil userInfo:nil];
    }
}

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

- (NSString *)resourceCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationType_HorizontalList:
            return kJMHorizontalResourceCell;
        case JMResourcesRepresentationType_Grid:
            return kJMGridResourceCell;
        default:
            return nil;
    }
}

- (NSString *)loadingCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationType_HorizontalList:
            return kJMHorizontalLoadingCell;
        case JMResourcesRepresentationType_Grid:
            return kJMGridLoadingCell;
        default:
            return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    JSResourceLookup *resourcesLookup = [sender objectForKey:kJMResourceLookup];
    
    if ([destinationViewController respondsToSelector:@selector(setResourceLookup:)]) {
        [destinationViewController setResourceLookup:resourcesLookup];
    }
    
    if ([self isResourceSegue:segue]) {
        if ([destinationViewController respondsToSelector:@selector(setInputControls:)]) {
            NSArray *inputControls = [sender objectForKey:kJMInputControls];
            [destinationViewController setInputControls:[inputControls mutableCopy]];
        }
    } else if ([segue.identifier isEqualToString:kJMShowFolderContetnSegue]) {
        JMResourcesListLoader * listLoader = [NSClassFromString(@"JMRepositoryListLoader") new];
        listLoader.resourceLookup = resourcesLookup;
        listLoader.delegate = destinationViewController;
        [destinationViewController setResourceListLoader:listLoader];
        [destinationViewController setPresentingType:JMResourcesCollectionViewControllerPresentingType_Repository];
    }
}

#pragma mark - Actions
- (void)representationTypeButtonTapped:(id)sender
{
    self.representationType = [self getNextRepresentationTypeForType:self.representationType];
    [self replaceRightNavigationItem:sender withItem:[self resourceRepresentationItem]];
}

- (void)refershControlAction:(id)sender
{
    [self.refreshControl endRefreshing];
    [self.resourceListLoader setNeedsUpdate];
    [self.resourceListLoader updateIfNeeded];
}

- (void)sortByButtonTapped:(id)sender
{
    JMSortOptionsPopupView *sortPopup = [[JMSortOptionsPopupView alloc] initWithDelegate:self type:JMPopupViewType_ContentViewOnly];
    sortPopup.sortBy = self.resourceListLoader.sortBy;
    [sortPopup show];
}

- (void)filterByButtonTapped:(id)sender
{
    JMFilterOptionsPopupView *filterPopup = [[JMFilterOptionsPopupView alloc] initWithDelegate:self type:JMPopupViewType_ContentViewOnly];
    filterPopup.objectType = self.resourceListLoader.resourcesType;
    [filterPopup show];
}

- (void)actionButtonClicked:(id) sender
{
    JMMenuActionsView *actionsView = [[JMMenuActionsView alloc] initWithFrame:CGRectMake(0, 0, 240, 200)];
    actionsView.delegate = self;
    actionsView.availableActions = [self availableAction];
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    self.popoverView = [PopoverView showPopoverAtPoint:point inView:self.view withTitle:nil withContentView:actionsView delegate:self];
}

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_None;
    switch (self.presentingType) {
        case JMResourcesCollectionViewControllerPresentingType_Library:{
            if([self.resourceListLoader.resourceClient.serverInfo.edition isEqualToString:self.resourceListLoader.constants.SERVER_EDITION_PRO]) {
                availableAction |= JMMenuActionsViewAction_Filter;
            }
        }
        case JMResourcesCollectionViewControllerPresentingType_SavedItems:{
            availableAction |= JMMenuActionsViewAction_Sort;
            break;
        }
        default:
            break;
    }
    return availableAction;
}

- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self.resourceListLoader.resources objectAtIndex:indexPath.row];
    if ([resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_REPORT_UNIT]) {
        if ([JMSavedResources savedReportsFromResourceLookup:resourceLookup]) {
            [self performSegueWithIdentifier:kJMShowSavedRecourcesViewerSegue sender:[NSDictionary dictionaryWithObject:resourceLookup forKey:kJMResourceLookup]];
        } else {
            [self fetchInputControlsForReport:resourceLookup];
        }
    } else if ([resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_DASHBOARD] || [resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_DASHBOARD_LEGACY]) {
        [self performSegueWithIdentifier:kJMShowDashboardViewerSegue sender:[NSDictionary dictionaryWithObject:resourceLookup forKey:kJMResourceLookup]];
    } else if ([resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_FOLDER]) {
        [self performSegueWithIdentifier:kJMShowFolderContetnSegue sender:[NSDictionary dictionaryWithObject:resourceLookup forKey:kJMResourceLookup]];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.resourceListLoader.resources.count;
    if ([self.resourceListLoader hasNextPage]) count++;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.resourceListLoader.resources.count) {
        if ([self.resourceListLoader hasNextPage]) {
            [self.resourceListLoader loadNextPage];
        }
        return [collectionView dequeueReusableCellWithReuseIdentifier:[self loadingCellForRepresentationType:self.representationType] forIndexPath:indexPath];
    }

    JMResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self resourceCellForRepresentationType:self.representationType] forIndexPath:indexPath];
    cell.resourceLookup = [self.resourceListLoader.resources objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
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

#pragma mark -
#pragma mark - JMPopupDelegate
- (void)popupViewWillShow:(JMPopupView *)popup
{
    [self.view endEditing:YES];
}

- (void)popupViewValueDidChanged:(id)popup
{
    if ([popup isKindOfClass:[JMSortOptionsPopupView class]]) {
        self.resourceListLoader.sortBy = [popup sortBy];
    } else if ([popup isKindOfClass:[JMFilterOptionsPopupView class]]) {
        self.resourceListLoader.resourcesType = [popup objectType];
    }
    [self.resourceListLoader setNeedsUpdate];
    [self.resourceListLoader updateIfNeeded];
}

#pragma mark - Utils

- (void)updateIfNeeded
{
    if (self.needReloadData) {
        [self.collectionView reloadData];
        self.needReloadData = NO;
    }

    if (self.needLayoutUI) {
        if ([JMUtils isIphone]) {
            [self showNavigationItems];
        }
        self.needLayoutUI = NO;
    }
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:self.searchBarPlaceholder.bounds];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = JMCustomLocalizedString(@"detail.search.resources.placeholder", nil);
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void) showNavigationItems
{
    NSMutableArray *navBarItems = [NSMutableArray array];
    JMMenuActionsViewAction availableAction = [self availableAction];
    if (availableAction & JMMenuActionsViewAction_Filter) {
        UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_action"] style:UIBarButtonItemStyleBordered target:self action:@selector(filterByButtonTapped:)];
        [navBarItems addObject:filterItem];
    }
    if (availableAction & JMMenuActionsViewAction_Sort) {
        UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort_action"] style:UIBarButtonItemStyleBordered target:self action:@selector(sortByButtonTapped:)];
        [navBarItems addObject:sortItem];
    }

    BOOL shouldConcateItems = ([JMUtils isIphone] && [navBarItems count] > 1) && (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation) ||
                           (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation) &&
                            UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)));
    
    if (shouldConcateItems) {
        navBarItems = [NSMutableArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)]];
    }
    [navBarItems addObject:[self resourceRepresentationItem]];
    
    UIView *searchContainerView = [[UIView alloc] initWithFrame:self.searchBar.bounds];
    searchContainerView.backgroundColor = [UIColor clearColor];
    [searchContainerView addSubview: self.searchBar];

    self.searchBar.autoresizingMask = searchContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.searchBarPlaceholder.topItem.titleView = searchContainerView;
    self.navigationItem.rightBarButtonItems = navBarItems;
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    [rightItems replaceObjectAtIndex:index withObject:newItem];
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (JMResourcesRepresentationType)getNextRepresentationTypeForType:(JMResourcesRepresentationType)currentType
{
    return (currentType == JMResourcesRepresentationTypeLast()) ? JMResourcesRepresentationTypeFirst() : currentType + 1;
}

- (NSString *)getRepresentationTypeKey
{
    NSString * keyString = @"RepresentationTypeKey";
    switch (self.presentingType) {
        case JMResourcesCollectionViewControllerPresentingType_Library:
            keyString = [@"Library" stringByAppendingString:keyString];
            break;
        case JMResourcesCollectionViewControllerPresentingType_Repository:
            keyString = [@"Repository" stringByAppendingString:keyString];
            break;
        case JMResourcesCollectionViewControllerPresentingType_SavedItems:
            keyString = [@"SavedItems" stringByAppendingString:keyString];
            break;
        case JMResourcesCollectionViewControllerPresentingType_Favorites:
            keyString = [@"Favorites" stringByAppendingString:keyString];
            break;
    }
    return keyString;
}

- (UIBarButtonItem *)resourceRepresentationItem
{
    NSString *imageName = ([self getNextRepresentationTypeForType:self.representationType] == JMResourcesRepresentationType_Grid) ? @"grid_button" : @"horizontal_list_button";
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStyleBordered target:self action:@selector(representationTypeButtonTapped:)];
}

- (JMResourcesListLoader *)resourceListLoader
{
    if (!_resourceListLoader) {
        switch (self.presentingType) {
            case JMResourcesCollectionViewControllerPresentingType_Library:
                _resourceListLoader = [NSClassFromString(@"JMLibraryListLoader") new];
                break;
            case JMResourcesCollectionViewControllerPresentingType_Repository:
                _resourceListLoader = [NSClassFromString(@"JMRepositoryListLoader") new];
                break;
            case JMResourcesCollectionViewControllerPresentingType_SavedItems:
                _resourceListLoader = [NSClassFromString(@"JMSavedResourcesListLoader") new];
                break;
            case JMResourcesCollectionViewControllerPresentingType_Favorites:
                _resourceListLoader = [NSClassFromString(@"JMFavoritesListLoader") new];
                break;
        }
        _resourceListLoader.delegate = self;
    }
    return _resourceListLoader;
}

#pragma mark -
#pragma mark - JMResourcesListLoaderDelegate
- (void)resourceListDidStartLoading:(JMResourcesListLoader *)listLoader
{
    self.needReloadData = YES;
    self.activityView.hidden = NO;
    self.noResultsViewTitleLabel.hidden = YES;
}

- (void)resourceListDidLoaded:(JMResourcesListLoader *)listLoader withError:(NSError *)error
{
    if (error) {
        self.activityView.hidden = YES;
        // TODO: add an error handler
    } else {
        self.noResultsViewTitleLabel.hidden = listLoader.resources.count > 0;
        self.activityView.hidden = YES;
        self.needReloadData = YES;
    }
}

#pragma mark -
#pragma mark - JMResourceCollectionViewCellDelegate
- (void)infoButtonDidTappedOnCell:(JMResourceCollectionViewCell *)cell
{
    [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:[NSDictionary dictionaryWithObject:cell.resourceLookup forKey:kJMResourceLookup]];
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    [self.popoverView animateRotationToNewPoint:point inView:self.view withDuration:duration];
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
@end