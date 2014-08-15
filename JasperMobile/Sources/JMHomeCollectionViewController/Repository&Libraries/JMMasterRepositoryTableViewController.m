//
//  JMMasterRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/13/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterRepositoryTableViewController.h"
#import "JMMasterResourcesTableViewController.h"
#import "JMBackHeaderView.h"
#import "JMRequestDelegate.h"
#import "JMConstants.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMFolderCellIdentifier = @"FolderCell";
static NSString * const kJMLoadingCellIdentifier = @"LoadingCell";

static NSString * const kJMShowResourcesSegue = @"ShowResources";

static NSInteger const kJMLimit = 15;

@interface JMMasterRepositoryTableViewController()
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, weak) JSConstants *constants;
@end

@implementation JMMasterRepositoryTableViewController
objection_requires(@"resourceClient", @"constants")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize offset = _offset;
@synthesize totalCount = _totalCount;

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (!self.resourceLookup) {
        self.resourceLookup = [[JSResourceLookup alloc] init];
        self.resourceLookup.label = @"Root";
        self.resourceLookup.uri = @"/";
        
        CGRect frame = self.tableView.frame;
        frame = CGRectMake(0, self.rootFolderView.frame.size.height, frame.size.width, frame.size.height + self.backView.frame.size.height);
        self.tableView.frame = frame;
        
        frame = self.rootFolderView.frame;
        self.rootFolderView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.backView.hidden = YES;
        self.backView.frame = CGRectZero;
    } else {
        [self.backView setOnTapGestureCallback:^(UITapGestureRecognizer *recognizer) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate loadResourcesIntoDetailViewController];
        }];
    }
    
    self.rootFolderLabel.text = self.resourceLookup.label;
    self.folders = [NSMutableArray array];
    
    [self loadNextPage];
}

// TODO: remove duplications
- (void)showResourcesListInMaster:(NSNotification *)notification
{
    [self performSegueWithIdentifier:kJMShowResourcesSegue sender:notification.userInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showResourcesListInMaster:)
                                                 name:kJMShowResourcesListInMaster
                                               object:nil];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kJMShowResourcesSegue]) {
        NSDictionary *userInfo = sender;
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setTotalCount:[[userInfo objectForKey:kJMTotalCount] integerValue]];
        [destinationViewController setOffset:[[userInfo objectForKey:kJMOffset] integerValue]];
        [destinationViewController setResources:[[userInfo objectForKey:kJMResources] mutableCopy]];
        [destinationViewController setResourceLookup:self.resourceLookup];
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        JSResourceLookup *selectedFolder = [self.folders objectAtIndex:indexPath.row];
        [segue.destinationViewController setResourceLookup:selectedFolder];
        [segue.destinationViewController setDelegate:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.folders.count;
    if (count > 0 && self.hasNextPage) count++;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.folders.count) {
        return [tableView dequeueReusableCellWithIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMFolderCellIdentifier forIndexPath:indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = [[self.folders objectAtIndex:indexPath.row] label];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasNextPage && indexPath.row == self.folders.count) {
        [self loadNextPage];
    }
}

#pragma mark - JMMasterRepositoryTableViewController

- (void)loadResourcesIntoDetailViewController
{
    NSDictionary *userInfo = @{
            kJMResourceLookup : self.resourceLookup,
            kJMLoadRecursively : @(NO),
            kJMSearchQuery : self.searchQuery ?: @""
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoadResourcesInDetail
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - JMPagination

- (void)loadNextPage
{
    __weak JMMasterRepositoryTableViewController *weakSelf = self;
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        if (!weakSelf.totalCount) {
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        weakSelf.offset += kJMLimit;
        [weakSelf.folders addObjectsFromArray:result.objects];
        [weakSelf.tableView reloadData];
        [weakSelf loadResourcesIntoDetailViewController];
    }];
    
    [self.resourceClient resourceLookups:self.resourceLookup.uri query:nil types:@[self.constants.WS_TYPE_FOLDER] recursive:NO offset:self.offset limit:kJMLimit delegate:delegate];
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
}

#pragma mark - JMSearchBarAdditions

- (void)searchWithQuery:(NSString *)query
{
    self.searchQuery = query;
    [self loadResourcesIntoDetailViewController];
}

- (void)didClearSearch
{
    if (self.searchQuery.length) {
        self.searchQuery = nil;
        [self loadResourcesIntoDetailViewController];
    }
}

- (NSString *)currentQuery
{
    return self.searchQuery;
}
#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    self.offset = 0;
    [self.folders removeAllObjects];
    [self.tableView reloadData];
    [self loadNextPage];
    [self loadResourcesIntoDetailViewController];
}

@end
