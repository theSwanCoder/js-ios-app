//
//  JMResourcesCollectionViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/16/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourcesCollectionViewController.h"
#import "JMRequestDelegate.h"
#import "JMRefreshable.h"
#import "JMResourceCollectionViewCell.h"
#import "JMLoadingCollectionViewCell.h"
#import "UIViewController+fetchInputControls.h"

#import "JMReportViewerViewController.h"
#import "JMReportOptionsViewController.h"

#import "DDSlidingView.h"

#import "JMSearchBarAdditions.h"
#import "JMSearchBar.h"

#import <Objection-iOS/JSObjection.h>
#import <Objection-iOS/Objection.h>

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationTypeHorizontalList = 0,
    JMResourcesRepresentationTypeGrid,
    JMResourcesRepresentationTypeVerticalList
};

static NSString * const kJMMasterViewControllerSegue = @"MasterViewController";

@interface JMResourcesCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, JMSearchBarDelegate>

@property (strong, nonatomic) DDSlidingView  *slideContainerView;
@property (weak, nonatomic) UINavigationController *masterNavigationController;

@property (strong, nonatomic) IBOutletCollection(UICollectionView) NSArray *collectionViews;

// Activity View
@property (nonatomic, weak) IBOutlet UIView *activityView;
@property (nonatomic, weak) IBOutlet UILabel *activityViewTitleLabel;
// noResults view
@property (nonatomic, weak) IBOutlet UIView *noResultsView;
@property (nonatomic, weak) IBOutlet UILabel *noResultsViewTitleLabel;

@property (nonatomic, assign) JMResourcesRepresentationType representationType;

// Params for loading request.
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, strong) NSString *sortBy;
@property (nonatomic, assign) BOOL loadRecursively;
@end

@implementation JMResourcesCollectionViewController
objection_requires(@"resourceClient", @"constants")

@synthesize resources = _resources;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceClient = _resourceClient;
@synthesize totalCount = _totalCount;
@synthesize offset = _offset;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
    
    @try {
        [self performSegueWithIdentifier:kJMMasterViewControllerSegue sender:self];
    } @catch (NSException *exception) {
        NSLog(@"No segue to master view controller");
    }
    
    self.activityViewTitleLabel.text = JMCustomLocalizedString(@"detail.resourcesloading.msg", nil);
    self.noResultsViewTitleLabel.text = JMCustomLocalizedString(@"detail.noresults.msg", nil);
    
    self.activityViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    self.noResultsViewTitleLabel.font = [JMFont resourcesActivityTitleFont];

    self.resources = [NSMutableArray array];
    
    NSArray *paramsArray = @[
                             @{kJMResourceCellNibKey: kJMHorizontalResourceCellNib,
                               kJMLoadingCellNibKey:  kJMHorizontalLoadingCellNib},
                             @{kJMResourceCellNibKey: kJMGridResourceCellNib,
                               kJMLoadingCellNibKey:  kJMGridLoadingCellNib},
                             @{kJMResourceCellNibKey: kJMVerticalResourceCellNib,
                               kJMLoadingCellNibKey:  kJMVerticalLoadingCellNib},
                             ];
    
    for (int i = 0; i < [self.collectionViews count]; i++) {
        UICollectionView *collectionView = [self.collectionViews objectAtIndex:i];
        [collectionView registerNib:[UINib nibWithNibName:[[paramsArray objectAtIndex:i] objectForKey:kJMResourceCellNibKey] bundle:nil] forCellWithReuseIdentifier:kJMResourceCellIdentifier];
        [collectionView registerNib:[UINib nibWithNibName:[[paramsArray objectAtIndex:i] objectForKey:kJMLoadingCellNibKey] bundle:nil] forCellWithReuseIdentifier:kJMLoadingCellIdentifier];
    }
    
    
    self.resourcesTypes = @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];
    
    // Will show horizontal list view controller
    self.representationType = JMResourcesRepresentationTypeHorizontalList;
    [self showNavigationItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadResourcesInDetail:)
                                                 name:kJMLoadResourcesInDetail
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        self.slideContainerView.hidden = YES;
    }
    [super viewWillDisappear:animated];
}

- (DDSlidingView *) slideContainerView
{
    if (!_slideContainerView) {
        UIImage * openImg = [UIImage imageNamed: @"open_panel.png"];
        UIImage * closeImg = [UIImage imageNamed: @"close_panel.png"];
        _slideContainerView = [[DDSlidingView alloc] initWithPosition: DDSliderPositionLeft image: openImg length: kJMMasterViewWidth];
        _slideContainerView.animationDuration = 0.2f;
        [_slideContainerView attachToView:self.view];
        
        _slideContainerView.hideSliderImage = closeImg;
    }
    return _slideContainerView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:kJMMasterViewControllerSegue]) {
        self.definesPresentationContext = YES;
        [self addChildViewController:destinationViewController];
        
        [self.slideContainerView setControllerSubview: [destinationViewController view]];
        self.slideContainerView.viewController = destinationViewController;
        [destinationViewController didMoveToParentViewController:self];
        
        // FIXME = addConstraints
        self.slideContainerView.clipsToBounds = YES;
        
        if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
            self.masterNavigationController = destinationViewController;
        }
    } else if ([self isResourceSegue:segue]) {
        JSResourceLookup *resourcesLookup = [sender objectForKey:kJMResourceLookup];
        NSArray *inputControls = [sender objectForKey:kJMInputControls];
        [destinationViewController setInputControls:[inputControls mutableCopy]];
        [destinationViewController setResourceLookup:resourcesLookup];
    }
}

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    UICollectionView *collectionView = [self.collectionViews objectAtIndex:JMResourcesRepresentationTypeHorizontalList];
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    
    CGFloat width = collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    flowLayout.itemSize = CGSizeMake(width, flowLayout.itemSize.height);
    
    [flowLayout invalidateLayout]; //force the elements to get laid out again with the new size
}

#pragma mark - Actions

- (void)searchButtonTapped:(id)sender
{
    CGRect searchBarFrame = [JMUtils isIphone] ? self.navigationController.navigationBar.bounds : CGRectMake(0, 0, 320, 44);
    JMSearchBar *searchBar =  [[JMSearchBar alloc] initWithFrame:searchBarFrame];
    searchBar.delegate = self;
    searchBar.placeholder = JMCustomLocalizedString(@"search.resources.placeholder", nil);
    
    if ([JMUtils isIphone]) {
        self.navigationItem.hidesBackButton = YES;
        [self.navigationController.navigationBar addSubview:searchBar];
    } else {
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        [self replaceRightNavigationItem:sender withItem:searchItem];
    }
}

- (void)representationTypeButtonTapped:(id)sender
{
    self.representationType = [self getNextRepresentationTypeForType:self.representationType];
    [self replaceRightNavigationItem:sender withItem:[self resourceRepresentationItem]];
}

- (void)refreshButtonTapped:(id)sender
{
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMRefreshable)]) {
        [visibleViewController refresh];
    }
}

- (void)setRepresentationType:(JMResourcesRepresentationType)representationType
{
    UICollectionView *currentView = [self.collectionViews objectAtIndex:_representationType];
    UICollectionView *nextView = [self.collectionViews objectAtIndex:representationType];
    [nextView setContentOffset:CGPointMake(0, 0)];

    [UIView beginAnimations:nil context:nil];
    currentView.alpha = 0;
    nextView.alpha = 1;
    [UIView commitAnimations];
    
    _representationType = representationType;
}

- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self.resources objectAtIndex:indexPath.row];
    
    if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        [self fetchInputControlsForReport:resourceLookup];
    } else {
        NSDictionary *data = @{
                               kJMResourceLookup : resourceLookup
                               };
        [self performSegueWithIdentifier:kJMShowDashboardViewerSegue sender:data];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.resources.count;
    if ([self hasNextPage]) count++;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.resources.count) {
        if (self.hasNextPage) {
            [self loadNextPage];
        }
        return [collectionView dequeueReusableCellWithReuseIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];
    }

    JMResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];
    cell.resourceLookup = [self.resources objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelectResourceAtIndexPath:indexPath];
}

#pragma mark - Pagination

- (void)loadNextPage
{
    // Multiple calls protection
    static BOOL isLoading = NO;
    if (isLoading) return;
    
    if (!self.resources.count) {
        self.activityView.hidden = NO;
        self.noResultsView.hidden = YES;
    }

    __weak JMResourcesCollectionViewController *weakSelf = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        isLoading = NO;
        
        if (!weakSelf.totalCount) {
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        [weakSelf.resources addObjectsFromArray:result.objects];
        weakSelf.offset += kJMResourceLimit;
        
        weakSelf.activityView.hidden = YES;
        weakSelf.noResultsView.hidden = weakSelf.resources.count > 0;
        [weakSelf.collectionViews makeObjectsPerformSelector:@selector(reloadData)];
    } errorBlock:^(JSOperationResult *result) {
        weakSelf.activityView.hidden = YES;
        isLoading = NO;
        // TODO: add an error handler
    }];

    [self.resourceClient resourceLookups:self.resourceLookup.uri query:self.searchQuery types:self.resourcesTypes
                                  sortBy:self.sortBy recursive:self.loadRecursively offset:self.offset limit:kJMResourceLimit delegate:delegate];
    isLoading = YES;
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
}

#pragma mark - Observer Methods

- (void)loadResourcesInDetail:(NSNotification *)notification
{
    // Reset state
    self.totalCount = 0;
    self.offset = 0;
    
    [self.resources removeAllObjects];
    [self.collectionViews makeObjectsPerformSelector:@selector(reloadData)];

    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo objectForKey:kJMResourcesTypes]) {
        self.resourcesTypes = [userInfo objectForKey:kJMResourcesTypes];
    }
    self.loadRecursively = [[userInfo objectForKey:kJMLoadRecursively] boolValue];
    self.resourceLookup = [userInfo objectForKey:kJMResourceLookup];
    self.searchQuery = [userInfo objectForKey:kJMSearchQuery];
    self.sortBy = [userInfo objectForKey:kJMSortBy];
    
    [self loadNextPage];
}

#pragma mark - JMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(JMSearchBar *)searchBar
{
    NSString *query = searchBar.text;
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMSearchBarAdditions)]) {
        if (![[visibleViewController currentQuery] isEqualToString:query]) {
            [visibleViewController searchWithQuery:query];
        }
    }
}

- (void)searchBarCancelButtonClicked:(JMSearchBar *) searchBar
{
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMSearchBarAdditions)]) {
        [visibleViewController didClearSearch];
    }

    if ([JMUtils isIphone]) {
        [searchBar removeFromSuperview];
        self.navigationItem.hidesBackButton = NO;
    } else {
        [self showNavigationItems];
    }
}

#pragma mark - Utils

- (void) showNavigationItems
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(searchButtonTapped:)];
    UIBarButtonItem *representationTypeItem = [self resourceRepresentationItem];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButtonTapped:)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshItem, representationTypeItem, searchItem, nil];
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
    if ([JMUtils isIphone]) {
        return (currentType == JMResourcesRepresentationTypeGrid) ? JMResourcesRepresentationTypeHorizontalList : JMResourcesRepresentationTypeGrid;
    }
    if (currentType == JMResourcesRepresentationTypeVerticalList) {
        return JMResourcesRepresentationTypeHorizontalList;
    }
    return (++currentType);
}

- (UIBarButtonItem *)resourceRepresentationItem
{
    NSString *imageName = nil;
    switch ([self getNextRepresentationTypeForType:self.representationType]) {
        case JMResourcesRepresentationTypeVerticalList:
            imageName = @"vertical_list_button.png";
            break;
        case JMResourcesRepresentationTypeHorizontalList:
            imageName = @"horizontal_list_button.png";
            break;
        case JMResourcesRepresentationTypeGrid:
            imageName = @"grid_button.png";
            break;
    }
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStyleBordered target:self action:@selector(representationTypeButtonTapped:)];
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end