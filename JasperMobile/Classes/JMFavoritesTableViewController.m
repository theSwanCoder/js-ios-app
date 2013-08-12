//
//  JMFavoritesTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 8/6/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMFavoritesTableViewController.h"
#import "JMFavoritesUtil.h"
#import <Objection-iOS/Objection.h>

@interface JMFavoritesTableViewController ()
@property (nonatomic, strong) JMFavoritesUtil *favoritesUtil;

- (void)checkAvailabilityOfEditButton;
@end

@implementation JMFavoritesTableViewController
objection_requires(@"favoritesUtil");

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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.resources || self.favoritesUtil.needsToRefreshFavorites) {
        self.resources = [self.favoritesUtil wrappersFromFavorites] ?: [NSArray array];
        self.favoritesUtil.needsToRefreshFavorites = NO;
        [self.tableView reloadData];
        [self checkAvailabilityOfEditButton];
    }
}

#pragma mark - UIViewControllerEditing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self checkAvailabilityOfEditButton];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JSResourceDescriptor *resource = [self.resources objectAtIndex:indexPath.row];
        [self.resources removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.favoritesUtil removeFromFavorites:resource];
    }
}

#pragma mark - Private

- (void)checkAvailabilityOfEditButton
{
    self.navigationItem.rightBarButtonItem.enabled = self.resources.count > 0;
}

@end
