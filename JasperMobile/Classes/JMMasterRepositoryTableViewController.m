 //
//  JMMasterRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/13/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterRepositoryTableViewController.h"
#import "JMBackHeaderView.h"
#import "JMRequestDelegate.h"
#import "JMPaginationData.h"
#import "JMConstants.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMShowResourcesSegue = @"ShowResources1";
static NSInteger const kJMLimit = 25;
static NSInteger const kJMRootFolderCell = 0;

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
    
    if (!self.resourceLookup) {
        self.resourceLookup = [[JSResourceLookup alloc] init];
        // TODO: localize
        self.resourceLookup.label = @"Root";
        // TODO: find prop value
        self.resourceLookup.uri = @"/";

        self.tableView.tableHeaderView.hidden = YES;
        self.tableView.tableHeaderView.frame = CGRectZero;
    } else {
        JMBackHeaderView *backView = (JMBackHeaderView *) self.tableView.tableHeaderView;
        [backView setOnTapGestureCallback:^(UITapGestureRecognizer *recognizer) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate loadResourcesIntoDetailViewController];
        }];
    }
    
    self.folders = [NSMutableArray array];
    [self.folders addObject:self.resourceLookup];
    
    [self loadNextPage];
}

// TODO: remove duplications
- (void)showResourcesListInMaster:(NSNotification *)notification
{
    [self performSegueWithIdentifier:kJMShowResourcesSegue sender:[notification.userInfo objectForKey:kJMPaginationData]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showResourcesListInMaster:)
                                                 name:kJMShowResourcesListInMaster
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kJMShowResourcesSegue]) {
        JMPaginationData *paginationData = sender;
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setTotalCount:paginationData.totalCount];
        [destinationViewController setResources:paginationData.resources];
        [destinationViewController setOffset:paginationData.offset];
        [destinationViewController setResourceLookup:paginationData.resourceLookup];
        [destinationViewController setResourcesTypes:@[self.constants.WS_TYPE_FOLDER]];
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
    if (self.hasNextPage) count++;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.folders.count) {
        return [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
    }

    NSString *cellIdentifier = (indexPath.row == kJMRootFolderCell) ? @"RootCell" : @"FolderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
    JMPaginationData *paginationData = [[JMPaginationData alloc] init];
    paginationData.resourceLookup = self.resourceLookup;
    paginationData.loadRecursively = NO;
    NSDictionary *userInfo = @{
        kJMPaginationData : paginationData
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoadResourcesInDetail
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - JMPagination

- (void)loadNextPage
{
    __weak  JMMasterRepositoryTableViewController *weakSelf = self;

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

@end
