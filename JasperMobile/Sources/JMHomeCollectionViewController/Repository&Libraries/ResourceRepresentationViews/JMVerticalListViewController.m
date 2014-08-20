//
//  JMVerticalListViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMVerticalListViewController.h"
#import "JMVerticalListResourceTableViewCell.h"
#import "JMConstants.h"
#import "UIViewController+FetchInputControls.h"
#import <Objection-iOS/Objection.h>

@implementation JMVerticalListViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.delegate.resources.count) {
        return 102.0f;
    }
    
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
        
        // TODO: Set translated text
        // TODO: transform (or create custom) activity indicator
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [super didSelectResourceAtIndexPath:indexPath];
}

#pragma mark - JMRefreshable

- (void)refresh
{
    [self.tableView reloadData];
}

@end
