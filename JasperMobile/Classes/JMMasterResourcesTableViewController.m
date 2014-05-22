//
//  JMMasterResourcesTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Objection-iOS/JSObjection.h>
#import <Objection-iOS/Objection.h>
#import "JMMasterResourcesTableViewController.h"
#import "JMRequestDelegate.h"
#import "JMPaginationData.h"
#import "JMConstants.h"

static NSInteger const kJMLimit = 15;
static NSString * const kJMResourceCell = @"ResourceCell";
static NSString * const kJMLoadingCell = @"LoadingCell";

@implementation JMMasterResourcesTableViewController
objection_requires(@"resourceClient")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
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
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    [self.tableView.tableHeaderView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.resources indexOfObject:self.resourceLookup] inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.resources.count;
    if (self.hasNextPage) count++;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.resources.count) {
        return [tableView dequeueReusableCellWithIdentifier:kJMLoadingCell forIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMResourceCell forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [[self.resources objectAtIndex:indexPath.row] label];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self.resources objectAtIndex:indexPath.row];
    self.resourceLookup = resourceLookup;
    // TODO: post notification to update report
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasNextPage && indexPath.row == self.resources.count) {
        [self loadNextPage];
    }
}

#pragma mark - Actions

- (IBAction)back:(UITapGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMShowResourcesListInDetail object:nil];
}

#pragma mark - Pagination

- (void)loadNextPage
{
    __weak JMMasterResourcesTableViewController *weakSelf = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        [weakSelf.resources addObjectsFromArray:result.objects];
        [weakSelf.tableView reloadData];
    } errorBlock:^(JSOperationResult *result) {
        weakSelf.offset -= kJMLimit;
        // TODO: add error handler
    }];

    [self.resourceClient resourceLookups:nil query:nil types:self.resourcesTypes recursive:YES offset:self.offset limit:kJMLimit delegate:delegate];
    self.offset += kJMLimit;
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
}

@end
