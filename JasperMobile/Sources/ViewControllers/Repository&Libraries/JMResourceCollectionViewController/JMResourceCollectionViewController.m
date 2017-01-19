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
//  JMResourceCollectionViewController.h
//  TIBCO JasperMobile
//


#import "JMResourceCollectionViewController.h"
#import "SWRevealViewController.h"
#import "JMLoadingCollectionViewCell.h"
#import "JMResourceCollectionViewCell.h"
#import "JMPopupView.h"
#import "PopoverView.h"
#import "JMListOptionsPopupView.h"
#import "JMCancelRequestPopup.h"
#import "JMAboutViewController.h"
#import "JMMenuItemControllersFactory.h"
#import "JMReportViewerVC.h"
#import "JMResourceInfoViewController.h"
#import "UIViewController+Additions.h"
#import "JMExportManager.h"
#import "JMResource.h"
#import "JMSchedule.h"
#import "JMWebViewManager.h"
#import "JMDashboardViewerVC.h"
#import "JMContentResourceViewerVC.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "JMThemesManager.h"

#import "JMScheduleManager.h"
#import "JMScheduleVC.h"
#import "JMLibraryListLoader.h"


CGFloat const kJMResourceCollectionViewGridWidth = 310;

CGFloat const kJMResourceCollectionViewCompactGridWidth = 150;

NSString * const kJMRepresentationTypeDidChangeNotification = @"JMRepresentationTypeDidChangeNotification";

@interface JMResourceCollectionViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
                                            UISearchBarDelegate, JMPopupViewDelegate, JMResourceCollectionViewCellDelegate,
                                            PopoverViewDelegate, JMMenuActionsViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *searchBarPlaceholder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarPlaceholderTopConstraint;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *activityViewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noResultsViewTitleLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, assign) BOOL isScrollToTop;
@property (nonatomic, assign) BOOL needReloadData;
@property (nonatomic, assign) BOOL needLayoutUI;
@property (nonatomic, assign) JMResourcesRepresentationType representationType;

@end

@implementation JMResourceCollectionViewController
@synthesize availableAction = _availableAction;

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.shouldShowButtonForChangingViewPresentation = YES;
    self.needShowSearchBar = YES;
    self.availableAction = JMMenuActionsViewAction_None;
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];
    
    self.searchBar.tintColor = [[JMThemesManager sharedManager] barItemsColor];
    self.searchBar.placeholder = JMLocalizedString(@"resources_search_placeholder");
   
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refershControlAction:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [[JMThemesManager sharedManager] resourceViewRefreshControlTintColor];
    [self.collectionView addSubview:self.refreshControl];
    
    self.collectionView.alwaysBounceVertical = YES;
    for (NSInteger i = JMResourcesRepresentationTypeFirst(); i <= JMResourcesRepresentationTypeLast(); i ++) {
        [self.collectionView registerNib:[UINib nibWithNibName:[self resourceCellForRepresentationType:i] bundle:nil]
              forCellWithReuseIdentifier:[self resourceCellForRepresentationType:i]];
        [self.collectionView registerNib:[UINib nibWithNibName:[self loadingCellForRepresentationType:i] bundle:nil]
              forCellWithReuseIdentifier:[self loadingCellForRepresentationType:i]];
    }
    
    self.activityViewTitleLabel.text = JMLocalizedString(@"resources_loading_msg");
    self.noResultsViewTitleLabel.text = self.noResultString;
    
    self.activityViewTitleLabel.font = [[JMThemesManager sharedManager] resourcesActivityTitleFont];
    self.noResultsViewTitleLabel.font = [[JMThemesManager sharedManager] resourcesActivityTitleFont];
    
    self.activityViewTitleLabel.textColor = [[JMThemesManager sharedManager] resourceViewActivityLabelTextColor];
    self.noResultsViewTitleLabel.textColor = [[JMThemesManager sharedManager] resourceViewNoResultLabelTextColor];
    self.activityIndicator.color = [[JMThemesManager sharedManager] resourceViewActivityActivityIndicatorColor];

    
    [self addObservers];

    self.isScrollToTop = NO;
    [self makeSearchBarVisible:[self needShowSearchBar]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self addKeyboardObservers];

    self.needLayoutUI = YES;

    if (self.needReloadData) {
        [self updateStrong];
    }
    [self.resourceListLoader updateIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self removeKeyboardObservers];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self isMenuShown]) {
        [self closeMenu];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.needReloadData = YES;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self showNavigationItemsForTraitCollection:newCollection];
}

#pragma mark - Setup
- (void)makeSearchBarVisible:(BOOL)visible
{
    self.searchBarPlaceholderTopConstraint.constant = visible ? 0 : (- CGRectGetHeight(self.searchBarPlaceholder.frame));
}

#pragma mark - Custom accessors
- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = _availableAction;
    NSArray *sortItems = [self.resourceListLoader listItemsWithOption:JMResourcesListLoaderOptionType_Sort];
    if ([sortItems count] > 1) {
        availableAction |= JMMenuActionsViewAction_Sort;
    }
    
    NSArray *filterItems = [self.resourceListLoader listItemsWithOption:JMResourcesListLoaderOptionType_Filter];
    if ([filterItems count] > 1) {
        availableAction |= JMMenuActionsViewAction_Filter;
    }
    return availableAction;
}

- (void)setNeedReloadData:(BOOL)needReloadData
{
    _needReloadData = needReloadData;
    [self updateIfNeeded];
}

- (void)setNeedLayoutUI:(BOOL)needLayoutUI
{
    _needLayoutUI = needLayoutUI;
    _needReloadData = needLayoutUI;
    
    [self updateIfNeeded];
}

- (void)setRepresentationType:(JMResourcesRepresentationType)representationType
{
    if (_representationType != representationType) {
        _representationType = representationType;
        [[NSUserDefaults standardUserDefaults] setInteger:representationType forKey:self.representationTypeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMRepresentationTypeDidChangeNotification object:nil];
    }
}

- (void)setRepresentationTypeKey:(NSString *)representationTypeKey
{
    if (![_representationTypeKey isEqualToString:representationTypeKey]) {
        _representationTypeKey = representationTypeKey;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:self.representationTypeKey]) {
            _representationType = [[NSUserDefaults standardUserDefaults] integerForKey:self.representationTypeKey];
        } else {
            _representationType = JMResourcesRepresentationTypeFirst();
        }
    }
}

#pragma mark - Actions
- (void)sortByButtonTapped:(id)sender
{
    JMListOptionsPopupView *sortPopup = [[JMListOptionsPopupView alloc] initWithDelegate:self
                                                                                    type:JMPopupViewType_ContentViewOnly
                                                                                 options:[self.resourceListLoader listItemsWithOption:JMResourcesListLoaderOptionType_Sort]];
    sortPopup.titleString = JMLocalizedString(@"resources_sortby_title");
    sortPopup.selectedIndex = self.resourceListLoader.sortBySelectedIndex;
    sortPopup.optionType = JMResourcesListLoaderOptionType_Sort;
    [sortPopup show];
}

- (void)filterByButtonTapped:(id)sender
{
    JMListOptionsPopupView *filterPopup = [[JMListOptionsPopupView alloc] initWithDelegate:self
                                                                                      type:JMPopupViewType_ContentViewOnly
                                                                                   options:[self.resourceListLoader listItemsWithOption:JMResourcesListLoaderOptionType_Filter]];
    filterPopup.titleString = JMLocalizedString(@"resources_filterby_title");
    filterPopup.selectedIndex = self.resourceListLoader.filterBySelectedIndex;
    filterPopup.optionType = JMResourcesListLoaderOptionType_Filter;
    [filterPopup show];
}

- (void)createNewScheduleTapped:(id)sender
{
    JMMenuItem *menuItem = [JMMenuItem menuItemWithItemType:JMMenuItemType_Library];
    UINavigationController *navigationVC = (UINavigationController *)[JMMenuItemControllersFactory viewControllerWithMenuItem:menuItem];
    JMResourceCollectionViewController *libraryViewController = (JMResourceCollectionViewController *)navigationVC.topViewController;
    libraryViewController.shouldShowButtonForChangingViewPresentation = NO;
    libraryViewController.availableAction = JMMenuActionsViewAction_None;
    libraryViewController.navigationItem.leftBarButtonItem = nil;
    libraryViewController.resourceListLoader.filterBySelectedIndex = JMLibraryListLoaderFilterIndexByReport;
    __weak __typeof(self) weakSelf = self;
    libraryViewController.actionBlock = ^(JMResource *resource) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf scheduleReportWithResource:resource];
    };
    [self.navigationController pushViewController:libraryViewController animated:YES];
}

- (void)scheduleReportWithResource:(JMResource *)resource
{
    JMScheduleVC *newJobVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
    [newJobVC createNewScheduleMetadataWithResourceLookup:resource];
    newJobVC.backButtonTitle = self.title;
    __weak __typeof(self) weakSelf = self;
    newJobVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata){
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.resourceListLoader setNeedsUpdate];
        [strongSelf.resourceListLoader updateIfNeeded];
    };
    [UIView beginAnimations:nil context:nil];
    NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
    [controllers removeLastObject];
    [controllers addObject:newJobVC];
    self.navigationController.viewControllers = controllers;
    [UIView commitAnimations];
}

- (void)refershControlAction:(id)sender
{
    if (!self.resourceListLoader.isLoadingNow) {
        [self.resourceListLoader setNeedsUpdate];
        [self.resourceListLoader updateIfNeeded];
    }
}

- (void)actionButtonClicked:(id) sender
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    [actionsView setAvailableActions:[self availableAction]
                     disabledActions:JMMenuActionsViewAction_None];
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
    if ([self isVisible]) {
        [self updateStrong];
    }
}

- (void) updateStrong
{
    if (self.needReloadData) {
        [self.collectionView reloadData];
        
        if (self.isScrollToTop) {
            self.isScrollToTop = NO;
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            if ([self.collectionView cellForItemAtIndexPath:firstItemIndexPath]) {
                [self.collectionView scrollToItemAtIndexPath:firstItemIndexPath
                                                          atScrollPosition:UICollectionViewScrollPositionBottom
                                                                  animated:NO];
            }
        }
        
        _needReloadData = NO;
    }
    
    if (self.needLayoutUI) {
        [self.popoverView dismiss:YES];
        [self showNavigationItemsForTraitCollection:self.traitCollection];
        _needLayoutUI = NO;
    }
}

#pragma mark - Overloaded methods
- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return [self.resourceListLoader resourceCount];
}

- (JMResource *)loadedResourceForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resourceListLoader resourceAtIndex:indexPath.row];
}

- (NSString *)noResultString
{
    if (!_noResultString) {
        _noResultString = JMLocalizedString(@"resources_noresults_msg");
    }
    return _noResultString;
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(representationTypeDidChange)
                                                 name:kJMRepresentationTypeDidChangeNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)representationTypeDidChange
{
    self.needReloadData = YES;
}

#pragma mark - Keyboard Observers
- (void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

}

- (void)removeKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)keyboardDidHide
{
    if (!self.searchBar.text.length) {
        [self.resourceListLoader clearSearchResults];
    }
}

#pragma mark - Setup Navigation Items
- (void) showNavigationItemsForTraitCollection:(UITraitCollection *)traitCollection
{
    if (traitCollection) {
        NSMutableArray *navBarItems = [NSMutableArray array];
        JMMenuActionsViewAction availableAction = [self availableAction];
        if (availableAction & JMMenuActionsViewAction_Filter) {
            UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_action"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(filterByButtonTapped:)];
            [navBarItems addObject:filterItem];
        }
        if (availableAction & JMMenuActionsViewAction_Sort) {
            UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort_action"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(sortByButtonTapped:)];
            [navBarItems addObject:sortItem];
        }
        if (availableAction & JMMenuActionsViewAction_Schedule) {
            UIBarButtonItem *scheduleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(createNewScheduleTapped:)];
            [navBarItems addObject:scheduleItem];
        }
        
        UIUserInterfaceSizeClass horizontalSizeClass = traitCollection.horizontalSizeClass;
        if (horizontalSizeClass == UIUserInterfaceSizeClassUnspecified && [JMUtils isIphone] && UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            horizontalSizeClass = UIUserInterfaceSizeClassCompact;
        }
        
        BOOL shouldConcateItems = (navBarItems.count > 1) && (horizontalSizeClass == UIUserInterfaceSizeClassCompact) &&
        (traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact);
        
        if (shouldConcateItems) {
            navBarItems = [@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(actionButtonClicked:)]] mutableCopy];
        }
        if (self.shouldShowButtonForChangingViewPresentation) {
            [navBarItems addObject:[self resourceRepresentationItem]];
        }
        self.navigationItem.rightBarButtonItems = navBarItems;
    } else {
        self.needLayoutUI = YES;
    }
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
- (void)showLoadingView
{
    [self.collectionView reloadData];
    self.activityViewTitleLabel.hidden = NO;
    self.activityIndicator.hidden = NO;
    self.noResultsViewTitleLabel.hidden = YES;
    self.collectionView.hidden = YES;
}

- (void)hideLoadingView
{
    [self.collectionView reloadData];
    [self.refreshControl endRefreshing];
    
    self.activityViewTitleLabel.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.collectionView.hidden = NO;
    
    self.noResultsViewTitleLabel.hidden = ![self collectionViewIsEmpty];
}

- (BOOL) collectionViewIsEmpty
{
    NSInteger sectionsCount = self.collectionView.numberOfSections;
    for (NSInteger section = 0; section < sectionsCount; section ++) {
        if ([self.collectionView numberOfItemsInSection:section]) {
            return NO;
        }
    }
    return YES;
}

- (NSString *)resourceCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationType_HorizontalList:
            return kJMHorizontalResourceCell;
        case JMResourcesRepresentationType_Grid:
            return kJMGridResourceCell;
    }
}

- (NSString *)loadingCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationType_HorizontalList:
            return kJMHorizontalLoadingCell;
        case JMResourcesRepresentationType_Grid:
            return kJMGridLoadingCell;
    }
}

- (UIBarButtonItem *)resourceRepresentationItem
{
    NSString *imageName = ([self nextRepresentationTypeForType:self.representationType] == JMResourcesRepresentationType_Grid) ? @"grid_button" : @"horizontal_list_button";
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                            style:UIBarButtonItemStylePlain
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
    JMResource *resource = [self loadedResourceForIndexPath:indexPath];
    __block id nextVC = nil;

    if (resource.type == JMResourceTypeFolder) {
        JMMenuItem *menuItem = [JMMenuItem menuItemWithItemType:JMMenuItemType_Repository];
        UINavigationController *navigationVC = (UINavigationController *)[JMMenuItemControllersFactory viewControllerWithMenuItem:menuItem];
        JMResourceCollectionViewController *repositoryViewController = (JMResourceCollectionViewController *)navigationVC.topViewController;
        repositoryViewController.resourceListLoader.resource = resource;
        repositoryViewController.navigationItem.leftBarButtonItem = nil;
        repositoryViewController.navigationItem.title = resource.resourceLookup.label;
        nextVC = repositoryViewController;
    } else if (resource.type == JMResourceTypeSchedule) {
        JMSchedule *schedule = (JMSchedule *) resource;
        [JMCancelRequestPopup presentWithMessage:@"status_loading"];

        __weak __typeof(self) weakSelf = self;
        [[JMScheduleManager sharedManager] loadScheduleMetadataForScheduleWithId:schedule.scheduleLookup.jobIdentifier completion:^(JSScheduleMetadata *metadata, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            [JMCancelRequestPopup dismiss];
            if (metadata) {
                JMScheduleVC *newScheduleVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
                [newScheduleVC updateScheduleMetadata:metadata];
                newScheduleVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata) {
                    [strongSelf.resourceListLoader setNeedsUpdate];
                    [strongSelf.resourceListLoader updateIfNeeded];
                };
                [strongSelf.navigationController pushViewController:newScheduleVC animated:YES];
            } else {
                [JMUtils presentAlertControllerWithError:error
                                              completion:nil];
            }
        }];
    } else if (resource.type == JMResourceTypeTempExportedReport) {
        // TODO: add canceling task
//        [[JMExportManager sharedInstance] cancelAll];
//        JMResourceCollectionViewCell *cell = (JMResourceCollectionViewCell *) [((JMBaseCollectionView *) self.view).collectionView cellForItemAtIndexPath:indexPath];
//        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:cell.resourceLookup];
//        [[JMExportManager sharedInstance] cancelTaskForSavedResource:savedReport];
    } else {
        NSString *resourceViewerVCIdentifier = [resource resourceViewerVCIdentifier];
        if (resourceViewerVCIdentifier) {
            nextVC = [self.storyboard instantiateViewControllerWithIdentifier:resourceViewerVCIdentifier];
            if ([nextVC respondsToSelector:@selector(setResource:)]) {
                [nextVC setResource:resource];
            }
            // Customizing report viewer view controller
            if (resource.type == JMResourceTypeReport) {
                JMReportViewerVC *reportViewerVC = (JMReportViewerVC *)nextVC;
                reportViewerVC.configurator = [JMUtils reportViewerConfiguratorReusableWebView];

                JMResourceCollectionViewCell *cell = (JMResourceCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
                JSReport *report = [reportViewerVC report];
                report.thumbnailImage = cell.thumbnailImage;
            } else if (resource.type == JMResourceTypeDashboard) {
                BOOL isSupportVisualize = [JMUtils isSupportVisualize];
                if (isSupportVisualize) {
                    JMDashboardViewerVC *dashboardViewerVC = nextVC;
                    dashboardViewerVC.configurator = [JMUtils dashboardViewerConfiguratorReusableWebView];
                } else {
                    JMDashboardViewerVC *dashboardViewerVC = nextVC;
                    dashboardViewerVC.configurator = [JMUtils dashboardViewerConfiguratorNonReusableWebView];
                }
            } else if (resource.type == JMResourceTypeLegacyDashboard) {
                JMDashboardViewerVC *dashboardViewerVC = nextVC;
                dashboardViewerVC.configurator = [JMUtils dashboardViewerConfiguratorNonReusableWebView];
            } else if (resource.type == JMResourceTypeFile || resource.type == JMResourceTypeSavedReport || resource.type == JMResourceTypeSavedDashboard) {
                JMContentResourceViewerVC *contentResourceViewerVC = nextVC;
                contentResourceViewerVC.configurator = [JMUtils contentResourceViewerConfigurator];
            }
        }
    }

    if (nextVC) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    rightItems[index] = newItem;
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (void)showResourceInfoViewControllerWithResourceLookup:(JMResource *)resource
{
    JMResourceInfoViewController *vc = (JMResourceInfoViewController *) [NSClassFromString([resource infoVCIdentifier]) new];
    vc.resource = resource;
    __weak __typeof(self) weakSelf = self;
    vc.exitBlock = ^(){
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.resourceListLoader setNeedsUpdate];
        [strongSelf.resourceListLoader updateIfNeeded];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIDocumentInteractionController *) setupDocumentControllerWithURL: (NSURL *) fileURL
                                                       usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
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
    if (indexPath.item == [self.resourceListLoader resourceCount]) {
        [self.resourceListLoader loadNextPage];
        return [collectionView dequeueReusableCellWithReuseIdentifier:[self loadingCellForRepresentationType:self.representationType] forIndexPath:indexPath];
    }
    
    JMResourceCollectionViewCell *cell = (JMResourceCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:[self resourceCellForRepresentationType:self.representationType]
                                                                                                                    forIndexPath:indexPath];
    cell.resource = [self loadedResourceForIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMenuShown]) {
        [self closeMenu];
    }
    if (self.actionBlock) {
        JMResource *resource = [self loadedResourceForIndexPath:indexPath];
        self.actionBlock(resource);
    } else {
        [self didSelectResourceAtIndexPath:indexPath];
    }
}


#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    
    CGFloat itemHeight = 80.f;
    CGFloat itemWidth = collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    
    if (self.representationType == JMResourcesRepresentationType_Grid) {
        NSInteger countOfCellsInRow = 0;
        CGFloat minItemWidth = [JMUtils isIphone] ? kJMResourceCollectionViewCompactGridWidth : kJMResourceCollectionViewGridWidth;
        itemWidth = minItemWidth;
        while (((countOfCellsInRow + 1) * itemWidth + countOfCellsInRow * flowLayout.minimumInteritemSpacing) <= (collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right)) {
            countOfCellsInRow ++;
        }
        
        CGFloat (^getItemWidth)(NSInteger) = ^CGFloat (NSInteger countOfCellsInRow){
            return floorf((collectionView.frame.size.width - flowLayout.sectionInset.left * (countOfCellsInRow + 1)) / countOfCellsInRow);
        };

        itemWidth = getItemWidth(countOfCellsInRow);
        if (itemWidth >= 1.5 * minItemWidth) {
            itemWidth = getItemWidth(++countOfCellsInRow);
        }
        
        itemHeight = [JMUtils isIphone] ? itemWidth : ceil(0.8*itemWidth);
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - JMResourceCollectionViewCellDelegate
- (void)infoButtonDidTappedOnCell:(JMResourceCollectionViewCell *)cell
{
    if ([self isMenuShown]) {
        [self closeMenu];
    }
    [self showResourceInfoViewControllerWithResourceLookup:cell.resource];
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
    switch (popup.optionType) {
        case JMResourcesListLoaderOptionType_Filter: {
            NSUInteger selectedIndex = [popup selectedIndex];
            if (selectedIndex != self.resourceListLoader.filterBySelectedIndex) {
                self.resourceListLoader.filterBySelectedIndex = selectedIndex;
                self.isScrollToTop = YES;
            }
            break;
        }
        case JMResourcesListLoaderOptionType_Sort: {
            NSUInteger selectedIndex = [popup selectedIndex];
            if (selectedIndex != self.resourceListLoader.sortBySelectedIndex) {
                self.resourceListLoader.sortBySelectedIndex = selectedIndex;
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
    [self showLoadingView];
}

- (void)resourceListLoaderDidEndLoad:(JMResourcesListLoader *)listLoader withResources:(NSArray *)resources
{
    [self hideLoadingView];
    self.needReloadData = YES;
}

- (void)resourceListLoaderDidFailed:(JMResourcesListLoader *)listLoader withError:(NSError *)error
{
    [self hideLoadingView];
    [JMUtils presentAlertControllerWithError:error completion:nil];
}

@end
