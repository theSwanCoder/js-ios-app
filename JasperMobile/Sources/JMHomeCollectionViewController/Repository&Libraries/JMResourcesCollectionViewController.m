//
//  JMResourcesCollectionViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/16/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourcesCollectionViewController.h"
#import "JMRefreshable.h"
#import "JMResourceCollectionViewCell.h"
#import "JMLoadingCollectionViewCell.h"
#import "UIViewController+fetchInputControls.h"

#import "JMReportViewerViewController.h"
#import "JMReportOptionsViewController.h"
#import "JMSavedResources+Helpers.h"
#import "JMSavedResourcesListLoader.h"

#import "DDSlidingView.h"

#import "JMSearchable.h"
#import "JMSearchBar.h"


typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationTypeHorizontalList = 0,
    JMResourcesRepresentationTypeGrid
};

static NSString * const kJMMasterViewControllerSegue = @"MasterViewController";

@interface JMResourcesCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JMSearchBarDelegate, JMResourcesListLoaderDelegate>
@property (weak, nonatomic) UINavigationController *masterNavigationController;

@property (strong, nonatomic) DDSlidingView  *slideContainerView;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (strong, nonatomic) IBOutletCollection(UICollectionView) NSArray *collectionViews;

@property (strong, nonatomic) JMSearchBar *searchBar;

// Activity View
@property (nonatomic, weak) IBOutlet UIView *activityView;
@property (nonatomic, weak) IBOutlet UILabel *activityViewTitleLabel;
// noResults view
@property (nonatomic, weak) IBOutlet UIView *noResultsView;
@property (nonatomic, weak) IBOutlet UILabel *noResultsViewTitleLabel;

@property (nonatomic, assign) JMResourcesRepresentationType representationType;

@end

@implementation JMResourcesCollectionViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];

    self.activityViewTitleLabel.text = JMCustomLocalizedString(@"detail.resourcesloading.msg", nil);
    self.noResultsViewTitleLabel.text = JMCustomLocalizedString(@"detail.noresults.msg", nil);
    
    self.activityViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    self.noResultsViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    
    NSArray *paramsArray = @[
                             @{kJMResourceCellNibKey: kJMHorizontalResourceCellNib,
                               kJMLoadingCellNibKey:  kJMHorizontalLoadingCellNib},
                             @{kJMResourceCellNibKey: kJMGridResourceCellNib,
                               kJMLoadingCellNibKey:  kJMGridLoadingCellNib}
                             ];
    
    for (int i = 0; i < [self.collectionViews count]; i++) {
        UICollectionView *collectionView = [self.collectionViews objectAtIndex:i];
        [collectionView registerNib:[UINib nibWithNibName:[[paramsArray objectAtIndex:i] objectForKey:kJMResourceCellNibKey] bundle:nil] forCellWithReuseIdentifier:kJMResourceCellIdentifier];
        [collectionView registerNib:[UINib nibWithNibName:[[paramsArray objectAtIndex:i] objectForKey:kJMLoadingCellNibKey] bundle:nil] forCellWithReuseIdentifier:kJMLoadingCellIdentifier];
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(refershControlAction:) forControlEvents:UIControlEventValueChanged];
        [collectionView addSubview:refreshControl];
        collectionView.alwaysBounceVertical = YES;
    }
    
    self.resourceListLoader.resourcesTypes = @[self.resourceListLoader.constants.WS_TYPE_REPORT_UNIT, self.resourceListLoader.constants.WS_TYPE_DASHBOARD];
    
    // Will show horizontal list view controller
    self.representationType = JMResourcesRepresentationTypeHorizontalList;
    [self showNavigationItems];
    
    @try {
        [self performSegueWithIdentifier:kJMMasterViewControllerSegue sender:self];
    } @catch (NSException *exception) {
        NSLog(@"No segue to master view controller");
    }
    if (![JMUtils isIphone]) {
        [self.slideContainerView showSlider];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.resourceListLoader updateIfNeeded];
    
    if ([JMUtils isIphone]) {
        id visibleViewController = self.masterNavigationController.visibleViewController;
        if ([visibleViewController conformsToProtocol:@protocol(JMSearchable)] && [visibleViewController currentQuery]) {
            [self showSearchBarWithText:[visibleViewController currentQuery]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        self.slideContainerView.hidden = YES;
    }
    
    if ([JMUtils isIphone]) {
        [self hideSearchBar];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UICollectionView *collectionView = [self.collectionViews objectAtIndex:self.representationType];
    [collectionView reloadData];
}

- (DDSlidingView *) slideContainerView
{
    if (!_slideContainerView) {
        UIImage * openImg = [UIImage imageNamed: @"open_panel"];
        UIImage * closeImg = [UIImage imageNamed: @"close_panel"];
        _slideContainerView = [[DDSlidingView alloc] initWithPosition: DDSliderPositionLeft image: openImg length: kJMMasterViewWidth];
        _slideContainerView.animationDuration = 0.2f;
        [_slideContainerView attachToView:self.view];
        
        NSLayoutConstraint *contentViewConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.contentContainerView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:_slideContainerView
                                                     attribute:NSLayoutAttributeTrailing
                                                     multiplier:1.0
                                                     constant:0];
        [self.view addConstraint:contentViewConstraint];
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

- (void)setResourceListLoader:(JMResourcesListLoader *)resourceListLoader
{
    _resourceListLoader = resourceListLoader;
    self.resourceListLoader.delegate = self;
}

#pragma mark - Actions

- (void)searchButtonTapped:(id)sender
{
    [self showSearchBarWithText:nil];
    [self.searchBar becomeFirstResponder];
}

- (void)representationTypeButtonTapped:(id)sender
{
    self.representationType = [self getNextRepresentationTypeForType:self.representationType];
    [self replaceRightNavigationItem:sender withItem:[self resourceRepresentationItem]];
}

- (void)refershControlAction:(id)sender
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
    JSResourceLookup *resourceLookup = [self.resourceListLoader.resources objectAtIndex:indexPath.row];
    if ([self.resourceListLoader isKindOfClass:[JMSavedResourcesListLoader class]]) {
        [self performSegueWithIdentifier:kJMShowSavedRecourcesViewerSegue sender:[NSDictionary dictionaryWithObject:resourceLookup forKey:kJMResourceLookup]];
    } else if ([resourceLookup.resourceType isEqualToString:self.resourceListLoader.constants.WS_TYPE_REPORT_UNIT]) {
        [self fetchInputControlsForReport:resourceLookup];
    } else {
        [self performSegueWithIdentifier:kJMShowDashboardViewerSegue sender:[NSDictionary dictionaryWithObject:resourceLookup forKey:kJMResourceLookup]];
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
        return [collectionView dequeueReusableCellWithReuseIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];
    }

    JMResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];
    cell.resourceLookup = [self.resourceListLoader.resources objectAtIndex:indexPath.row];
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
    if (collectionView == [self.collectionViews objectAtIndex:JMResourcesRepresentationTypeHorizontalList]) {
        CGFloat width = collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
        return CGSizeMake(width, flowLayout.itemSize.height);
    }
    return flowLayout.itemSize;
}

#pragma mark - JMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(JMSearchBar *)searchBar
{
    NSString *query = searchBar.text;
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMSearchable)]) {
        if (![[visibleViewController currentQuery] isEqualToString:query]) {
            [visibleViewController searchWithQuery:query];
        }
    }
}

- (void)searchBarCancelButtonClicked:(JMSearchBar *) searchBar
{
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMSearchable)]) {
        [visibleViewController didClearSearch];
    }

    [self hideSearchBar];
}

#pragma mark - Utils

- (void) showSearchBarWithText:(NSString *)text
{
    if (!self.searchBar) {
        CGRect searchBarFrame = [JMUtils isIphone] ? self.navigationController.navigationBar.bounds : CGRectMake(0, 0, 320, 44);
        self.searchBar =  [[JMSearchBar alloc] initWithFrame:searchBarFrame];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = JMCustomLocalizedString(@"detail.search.resources.placeholder", nil);
        self.searchBar.text = text;
    }

    if ([JMUtils isIphone]) {
        self.navigationItem.hidesBackButton = YES;
        [self.navigationController.navigationBar addSubview:self.searchBar];
    } else {
        for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
            if (item.action  == @selector(searchButtonTapped:)) {
                UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
                [self replaceRightNavigationItem:item withItem:searchItem];
                break;
            }
        }
    }
}

- (void) hideSearchBar
{
    if ([JMUtils isIphone]) {
        [self.searchBar removeFromSuperview];
        self.navigationItem.hidesBackButton = NO;
    } else {
        [self showNavigationItems];
    }
    self.searchBar = nil;
}

- (void) showNavigationItems
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(searchButtonTapped:)];
    UIBarButtonItem *representationTypeItem = [self resourceRepresentationItem];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:representationTypeItem, searchItem, nil];
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

#pragma mark - JMResourcesListLoaderDelegate
- (void)resourceListDidStartLoading:(JMResourcesListLoader *)listLoader
{
    [self.collectionViews makeObjectsPerformSelector:@selector(reloadData)];
    self.activityView.hidden = NO;
    self.noResultsView.hidden = YES;
}

- (void)resourceListDidLoaded:(JMResourcesListLoader *)listLoader withError:(NSError *)error
{
    if (error) {
        self.activityView.hidden = YES;
        // TODO: add an error handler
    } else {
        self.noResultsView.hidden = listLoader.resources.count > 0;
        self.activityView.hidden = YES;
        [self.collectionViews makeObjectsPerformSelector:@selector(reloadData)];
    }
}

@end