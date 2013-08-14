/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMFavoritesTableViewController.m
//  Jaspersoft Corporation
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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([super isNeedsToReloadData] || self.favoritesUtil.needsToRefreshFavorites) {
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
