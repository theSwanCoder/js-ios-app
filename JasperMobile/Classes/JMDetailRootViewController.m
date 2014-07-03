//
//  JMDetailNavigationViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/16/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMDetailRootViewController.h"
#import "JMRequestDelegate.h"
#import "JMRefreshable.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import <Objection-iOS/JSObjection.h>
#import <Objection-iOS/Objection.h>

static NSInteger const kJMLimit = 15;
static CGFloat const yOffset = 25;

@interface JMDetailRootViewController ()
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, weak) UIViewController <JMRefreshable> *activeRepresentationViewController;
@property (nonatomic, strong) NSDictionary *representationTypeToSegue;
@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, strong) NSString *sortBy;
@property (nonatomic, assign) BOOL loadRecursively;
@property (nonatomic, strong) JMResourcesRepresentationSwitcherActionBarView *actionBarView;
@end

@implementation JMDetailRootViewController
objection_requires(@"resourceClient", @"constants")

@synthesize resources = _resources;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceClient = _resourceClient;
@synthesize totalCount = _totalCount;
@synthesize offset = _offset;

#pragma mark - Accessors 

- (void)setRepresentationType:(JMResourcesRepresentationType)representationType
{
    if (_representationType != representationType) {
        if (_representationType) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        _representationType = representationType;
        [self performSegueWithIdentifier:[self.representationTypeToSegue objectForKey:@(self.representationType)] sender:self];
    }
}

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
    
    CGPoint center = CGPointMake(self.navigationController.view.center.x, self.navigationController.view.center.y - yOffset);
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
    self.activityIndicatorView.center = center;
    self.activityIndicatorView.hidden = YES;
    [self.navigationController.view addSubview:self.activityIndicatorView];
    
    self.noResultsView.center = CGPointMake(self.noResultsView.center.x, center.y);
    self.noResultsView.hidden = YES;
    [self.navigationController.view addSubview:self.noResultsView];
    
    // TODO: investigate universal storyboard localization
    self.activityIndicatorView.label.text = JMCustomLocalizedString(@"detail.resourcesloading.msg", nil);
    self.noResultsView.label.text = JMCustomLocalizedString(@"detail.noresults.msg", nil);
    
    self.resources = [NSMutableArray array];
    self.resourcesTypes = @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];
    self.representationTypeToSegue = @{
            @(JMResourcesRepresentationTypeGrid) : @"GridViewController",
            @(JMResourcesRepresentationTypeHorizontalList) : @"HorizontalListViewController",
            @(JMResourcesRepresentationTypeVerticalList) : @"VerticalListViewController"
    };
    
    if (!self.representationType) {
        // Will show horizontal list view controller
        self.representationType = JMResourcesRepresentationTypeHorizontalList;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadResourcesInDetail:)
                                                 name:kJMLoadResourcesInDetail
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showResourcesListInDetail:)
                                                 name:kJMShowResourcesListInDetail
                                               object:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // if changed representation type
    if ([self.representationTypeToSegue.allValues indexOfObject:segue.identifier] != NSNotFound) {
        id destinationViewController = [segue destinationViewController];
        [destinationViewController setDelegate:self];
        [destinationViewController refresh];
        self.activeRepresentationViewController = destinationViewController;
    }
}

#pragma mark - Pagination

- (void)loadNextPage
{
    // Multiple calls protection
    static BOOL isLoading = NO;
    if (isLoading) return;
    
    if (!self.resources.count) {
        self.activityIndicatorView.hidden = NO;
        self.noResultsView.hidden = YES;
    }

    __weak JMDetailRootViewController *weakSelf = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        isLoading = NO;
        
        if (!weakSelf.totalCount) {
            weakSelf.activeRepresentationViewController.needsToResetScroll = YES;
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        [weakSelf.resources addObjectsFromArray:result.objects];
        weakSelf.offset += kJMLimit;
        
        weakSelf.activityIndicatorView.hidden = YES;
        weakSelf.noResultsView.hidden = weakSelf.resources.count > 0;

        [weakSelf.activeRepresentationViewController refresh];
    } errorBlock:^(JSOperationResult *result) {
        isLoading = NO;
        // TODO: add an error handler
    }];

    [self.resourceClient resourceLookups:self.resourceLookup.uri query:self.searchQuery types:self.resourcesTypes
                                  sortBy:self.sortBy recursive:self.loadRecursively offset:self.offset limit:kJMLimit delegate:delegate];
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
    [self.activeRepresentationViewController refresh];

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

- (void)showResourcesListInDetail:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    self.offset = [[userInfo objectForKey:kJMOffset] integerValue];
    self.resources = [userInfo objectForKey:kJMResources];
    [self.activeRepresentationViewController refresh];
}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    if (!self.actionBarView) {
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass
                              ([JMResourcesRepresentationSwitcherActionBarView class])
                                                           owner:self
                                                         options:nil].firstObject;
        self.actionBarView.delegate = self;
    }
    
    return self.actionBarView;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.actionBarView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation JMDetailActivityIndicatorView
@end

@implementation JMDetailNoResultsView
@end
