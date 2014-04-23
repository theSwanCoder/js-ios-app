//
//  JMResourcesTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourcesTableViewController.h"

// TODO: OOP Part: Needs to be implemented in a proper way. REMOVE CODE DUPLICATION
#import <Objection-iOS/Objection.h>
#import "JMResourcesDataManager.h"
#import "JMResourceCell.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>

static NSString * const kJMLoadingCellIdentifier = @"LoadingCell";

@interface JMResourcesTableViewController()
@property (nonatomic, weak) JMResourcesDataManager *resourcesDataSource;
@property (nonatomic, assign) BOOL needsToUpdateScrollPosition;
@end

@implementation JMResourcesTableViewController
objection_requires(@"resourcesDataSource")

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
    self.needsToUpdateScrollPosition = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needsToUpdateScrollPosition && self.resourcesDataSource.firstVisibleResourceIndex > 0) {
        NSIndexPath *firstVisible = [NSIndexPath indexPathForItem:self.resourcesDataSource.firstVisibleResourceIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:firstVisible atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.needsToUpdateScrollPosition = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSIndexPath *firstVisible = self.tableView.indexPathsForVisibleRows[1];
    self.resourcesDataSource.firstVisibleResourceIndex = firstVisible.row;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.resourcesDataSource.resources.count;
//    if ([self.delegate hasNextPage]) count++;

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMResourceCell *cell;
    
    if (indexPath.row == self.resourcesDataSource.resources.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *) [cell viewWithTag:1];
        [indicator startAnimating];
        return cell;
    }

    JSResourceLookup *resource = [self.resourcesDataSource.resources objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];
    cell.label.text = resource.label;
    cell.desc.text = resource.resourceDescription;
    cell.creationDate.text = resource.creationDate;

//    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_prototype_image.png"]];
//    [cell.imageView removeFromSuperview];
//    [cell.contentView addSubview:view];
//    cell.imageView.frame = CGRectMake(0, 0, 106, 76);
//    cell.imageView.image = nil;
//    cell.imageView.layer.borderColor = [[UIColor redColor] CGColor];
//    cell.imageView.layer.borderWidth = 1.0f;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate hasNextPage] && indexPath.row == self.resourcesDataSource.resources.count) {
        [self.delegate loadNextPage];
    }
}

#pragma mark - JMRefreshable protocol

- (void)refresh
{
    [self.tableView reloadData];
}

@end
