//
//  JMBaseResourcesCollectionViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/5/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMBaseResourcesCollectionViewController.h"
#import "JMConstants.h"
#import "UIViewController+fetchInputControls.h"
#import <Objection-iOS/Objection.h>

static NSInteger const kJMPaginationTreshoald = 8;

@implementation JMBaseResourcesCollectionViewController
objection_requires(@"constants")

#pragma mark - Accessors

- (BOOL)isLoadingCell:(UICollectionViewCell *)cell
{
    return [cell.reuseIdentifier isEqualToString:kJMLoadingCellIdentifier];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reset scroll position for a new resources type
    if (self.needsToResetScroll) {
        self.collectionView.contentOffset = CGPointZero;
    }
}

#pragma mark - UICollectionViewControllerDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [super numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [super numberOfResourcesInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.delegate.resources.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];

        // TODO: Set translated text
        // TODO: transform (or create custom) activity indicator

        return cell;
    }

    return [collectionView dequeueReusableCellWithReuseIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat inset;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        inset = self.edgesLandscapeInset;
    } else {
        inset = self.edgesPortraitInset;
    }

    return UIEdgeInsetsMake(inset, inset, inset, inset);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate.hasNextPage && indexPath.item + kJMPaginationTreshoald >= self.delegate.resources.count) {
        [self.delegate loadNextPage];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super didSelectResourceAtIndexPath:indexPath];
}

#pragma mark - JMRefreshable

- (void)refresh
{
    // Reset scroll position for a new resources type
    if (self.needsToResetScroll) {
        self.collectionView.contentOffset = CGPointZero;
    }
    
    [self.collectionView reloadData];
}

@end
