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
#import "JMBackHeaderView.h"
#import "JMConstants.h"

static NSInteger const kJMLimit = 20;
static NSString * const kJMResourceCell = @"ResourceCell";
static NSString * const kJMLoadingCell = @"LoadingCell";

@implementation JMMasterResourcesTableViewController
objection_requires(@"resourceClient")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize totalCount = _totalCount;
@synthesize offset = _offset;
@synthesize resources = _resources;

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
    
    [self.backView setOnTapGestureCallback:^(UITapGestureRecognizer *recognizer) {
        [self back];
    }];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedResourceIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionMiddle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(back)
                                                 name:kJMShowRootMaster
                                               object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.resources.count;
    if (count > 0 && self.hasNextPage) count++;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.resources.count) {
        return [tableView dequeueReusableCellWithIdentifier:kJMLoadingCell forIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMResourceCell forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    JSResourceLookup *resourceLookup = [self.resources objectAtIndex:indexPath.row];
    label.text = resourceLookup.label;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedResourceIndex inSection:0] animated:NO];
    self.selectedResourceIndex = indexPath.row;
    // TODO: post notification to update report view
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasNextPage && indexPath.row == self.resources.count) {
        [self loadNextPage];
    }
    if (indexPath.row == self.selectedResourceIndex) {
        cell.selected = YES;
    }
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
    
    [self.resourceClient resourceLookups:self.resourceLookup.uri query:nil types:self.resourcesTypes sortBy:self.sortBy
                               recursive:self.loadRecursively offset:self.offset limit:kJMLimit delegate:delegate];
    
    self.offset += kJMLimit;
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    self.offset = 0;
    [self.resources removeAllObjects];
    [self.tableView reloadData];
    [self loadNextPage];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    
    NSDictionary *userInfo = @{
                               kJMOffset : @(self.offset),
                               kJMResources : self.resources
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMShowResourcesListInDetail object:nil userInfo:userInfo];
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
