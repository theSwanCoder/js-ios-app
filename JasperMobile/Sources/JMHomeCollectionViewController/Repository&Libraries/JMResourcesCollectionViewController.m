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

NSString * const kJMShowFolderContetnSegue = @"ShowFolderContetnSegue";

NSString * const kJMRepresentationTypeDidChangedNotification = @"kJMRepresentationTypeDidChangedNotification";
NSString * const kJMRepresentationTypeKey = @"kJMRepresentationTypeKey";

static inline JMResourcesRepresentationType JMResourcesRepresentationTypeFirst() { return JMResourcesRepresentationTypeHorizontalList; }
static inline JMResourcesRepresentationType JMResourcesRepresentationTypeLast() { return JMResourcesRepresentationTypeGrid; }

@interface JMResourcesCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, JMResourcesListLoaderDelegate, JMPopupViewDelegate, JMResourceCollectionViewCellDelegate>


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

@end

@implementation JMResourcesCollectionViewController

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
        self.needReloadData = YES;
    } @weakselfend];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kJMRepresentationTypeDidChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakselfnotnil(^(NSNotification *notification)) {
        self.representationType = [[notification.userInfo objectForKey:kJMRepresentationTypeKey] integerValue];
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
    if (self.needReloadData) {
        [self.collectionView reloadData];
        self.needReloadData = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.resourceListLoader updateIfNeeded];
}

- (void)setRepresentationType:(JMResourcesRepresentationType)representationType
{
    if (_representationType != representationType) {
        _representationType = representationType;
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMRepresentationTypeDidChangedNotification object:nil userInfo:@{kJMRepresentationTypeKey: @(representationType)}];
    }
}

- (void)setNeedReloadData:(BOOL)needReloadData
{
    _needReloadData = needReloadData;
    if (self.isViewLoaded && self.view.window && needReloadData) {
        [self.collectionView reloadData];
        _needReloadData = NO;
    }
}

- (NSString *)resourceCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationTypeHorizontalList:
            return kJMHorizontalResourceCell;
        case JMResourcesRepresentationTypeGrid:
            return kJMGridResourceCell;
        default:
            return nil;
    }
}

- (NSString *)loadingCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationTypeHorizontalList:
            return kJMHorizontalLoadingCell;
        case JMResourcesRepresentationTypeGrid:
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
        [destinationViewController setRepresentationType:self.representationType];
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

- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self.resourceListLoader.resources objectAtIndex:indexPath.row];
    if ([resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_REPORT_UNIT]) {
        if ([JMSavedResources savedReportsFromResourceLookup:resourceLookup]) {
            [self performSegueWithIdentifier:kJMShowSavedRecourcesViewerSegue sender:[NSDictionary dictionaryWithObject:resourceLookup forKey:kJMResourceLookup]];
        } else {
            [self fetchInputControlsForReport:resourceLookup];
        }
    } else if ([resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_DASHBOARD]) {
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
    
    if (self.representationType == JMResourcesRepresentationTypeGrid) {
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

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 250, 34)];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = JMCustomLocalizedString(@"detail.search.resources.placeholder", nil);
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void) showNavigationItems
{
    NSMutableArray *navBarItems = [NSMutableArray arrayWithObject:[self resourceRepresentationItem]];
    
    UIBarButtonItem *filterItem;
    UIBarButtonItem *sortItem;
    switch (self.presentingType) {
        case JMResourcesCollectionViewControllerPresentingType_Library:
            if([self.resourceListLoader.resourceClient.serverInfo.edition isEqualToString:self.resourceListLoader.constants.SERVER_EDITION_PRO]) {
                filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_action"] style:UIBarButtonItemStyleBordered target:self action:@selector(filterByButtonTapped:)];
            }
        case JMResourcesCollectionViewControllerPresentingType_SavedItems:
            sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort_action"] style:UIBarButtonItemStyleBordered target:self action:@selector(sortByButtonTapped:)];
            break;
        default:
            break;
    }
    
    if ([JMUtils isIphone]) {
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *titleView = [[UIView alloc] initWithFrame:self.searchBar.bounds];
        self.searchBar.autoresizingMask = titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        titleView.backgroundColor = [UIColor clearColor];
        [titleView addSubview: self.searchBar];
        self.searchBarPlaceholder.topItem.titleView = titleView;
        NSMutableArray *searchBarPlaceholderItems = [NSMutableArray array];
        if (sortItem) {
            [searchBarPlaceholderItems addObject:sortItem];
        }

        if (filterItem) {
            [searchBarPlaceholderItems addObject:filterItem];
        }
        
        self.searchBarPlaceholder.topItem.rightBarButtonItems = searchBarPlaceholderItems;
    } else {
        if (sortItem) {
            [navBarItems addObject:sortItem];
        }
        if (filterItem) {
            [navBarItems addObject:filterItem];
        }
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.searchBar.bounds];
        contentView.backgroundColor = [UIColor clearColor];
        [contentView addSubview:self.searchBar];
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:contentView];
        [navBarItems addObject:searchItem];
    }
    
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
    return (currentType == JMResourcesRepresentationTypeGrid) ? JMResourcesRepresentationTypeHorizontalList : JMResourcesRepresentationTypeGrid;
}

- (UIBarButtonItem *)resourceRepresentationItem
{
    NSString *imageName = ([self getNextRepresentationTypeForType:self.representationType] == JMResourcesRepresentationTypeGrid) ? @"grid_button" : @"horizontal_list_button";
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
@end