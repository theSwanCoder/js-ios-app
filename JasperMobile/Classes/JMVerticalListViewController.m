//
//  JMVerticalListViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMVerticalListViewController.h"

// TODO: OOP Part: Needs to be implemented in a proper way. REMOVE CODE DUPLICATION
#import "JMVerticalListResourceTableViewCell.h"
#import "JMConstants.h"

static NSString * const kJMLoadingCellIdentifier = @"LoadingCell";

@implementation JMVerticalListViewController

@synthesize needsToResetScroll = _needsToResetScroll;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reset scroll position for a new resources type
    if (self.needsToResetScroll) {
        self.tableView.contentOffset = CGPointZero;
    }
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
    NSInteger count = self.delegate.resources.count;
    if ([self.delegate hasNextPage]) count++;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMVerticalListResourceTableViewCell *cell;
    
    if (indexPath.row == self.delegate.resources.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *) [cell viewWithTag:1];
        [indicator startAnimating];
        return cell;
    }

    cell = [tableView dequeueReusableCellWithIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];

    // Preventing NPE because "delegate.resources" is a weak reference
    if (!self.delegate.resources.count) return cell;

    JSResourceLookup *resource = [self.delegate.resources objectAtIndex:indexPath.row];
    cell.label.text = resource.label;
    cell.desc.text = resource.resourceDescription;
    cell.creationDate.text = resource.creationDate;

    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_prototype_image.png"]];
    [cell.imageView removeFromSuperview];
    [cell.contentView addSubview:view];
    cell.imageView.frame = CGRectMake(0, 0, 106, 76);
    cell.imageView.image = nil;
    cell.imageView.layer.borderColor = [[UIColor redColor] CGColor];
    cell.imageView.layer.borderWidth = 1.0f;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate hasNextPage] && indexPath.row == self.delegate.resources.count) {
        [self.delegate loadNextPage];
    }
}

#pragma mark - JMRefreshable

- (void)refresh
{
    [self.tableView reloadData];
}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    return [self.delegate actionBar];
}

@end
