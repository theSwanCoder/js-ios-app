/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMResourcesCollectionViewController.m
//  Jaspersoft Corporation
//

#import "JMResourcesCollectionViewController.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>

static NSString * kJMResourceCellIdentifier = @"ResourceCell";
static NSString * kJMLoadingCellIdentifier = @"LoadingCell";
static NSInteger const kJMPaginationTreshoald = 3;

// TODO: OOP Part: Needs to be implemented in a proper way. REMOVE CODE DUPLICATION
#import <Objection-iOS/Objection.h>
#import "JMResourcesDataManager.h"

@interface JMResourcesCollectionViewController()
//@property (nonatomic, weak) JMResourcesDataManager *resourceDataSource;
@property (nonatomic, assign) BOOL needsToUpdateScrollPosition;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, weak) NSArray *resources;
@end

@implementation JMResourcesCollectionViewController
//objection_requires(@"resourceDataSource")

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
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.needsToUpdateScrollPosition = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"reload" object:nil];
}

- (void)reload:(NSNotification *)notification
{
    self.resources = notification.userInfo[@"resources"];
    self.hasNextPage = [notification.userInfo[@"hasNextPage"] boolValue];
    [self.collectionView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.isNeedsToUpdateScrollPosition &&
//            self.resourceDataSource.firstVisibleResourceIndex > 0) {
//        NSIndexPath *firstVisibile = [NSIndexPath indexPathForItem:self.resourceDataSource.firstVisibleResourceIndex inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:firstVisibile atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
//        self.isNeedsToUpdateScrollPosition = NO;
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSIndexPath *firstVisible = [self.collectionView.indexPathsForVisibleItems firstObject];
//    self.resourceDataSource.firstVisibleResourceIndex = firstVisible.row;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.resources.count;
//    if ([self.delegate hasNextPage]) count++;

    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;

    if (indexPath.row == self.resources.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];
        
        // TODO: Set translated text
        // TODO: transform (or create custom) activity indicator
        
        return cell;
    }

    cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];
    JSResourceLookup *lookup = [self.resources objectAtIndex:indexPath.row];
    
    UILabel *resourceLabel = (UILabel *) [cell viewWithTag:2];
    CGSize labelSize = [lookup.label sizeWithFont:resourceLabel.font constrainedToSize:CGSizeMake(300, 80) lineBreakMode:NSLineBreakByWordWrapping];
    resourceLabel.frame = CGRectMake(resourceLabel.frame.origin.x, resourceLabel.frame.origin.y, labelSize.width, labelSize.height);
    resourceLabel.text = lookup.label;

    UILabel *creationDate = (UILabel *) [cell viewWithTag:3];
    creationDate.text = lookup.creationDate;

    UILabel *description = (UILabel *) [cell viewWithTag:4];
    CGSize descriptionSize = [lookup.resourceDescription sizeWithFont:description.font constrainedToSize:CGSizeMake(300, 50) lineBreakMode:NSLineBreakByWordWrapping];
    description.frame = CGRectMake(description.frame.origin.x, description.frame.origin.y, descriptionSize.width, descriptionSize.height);
    description.text = lookup.resourceDescription;

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasNextPage && indexPath.row + kJMPaginationTreshoald == self.resources.count) {
//        [self.delegate loadNextPage];
    }
}

#pragma mark - JMRefreshable protocol

- (void)refresh
{
    [self.collectionView reloadData];
}

@end
