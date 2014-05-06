//
//  JMBaseResourcesCollectionViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/5/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMBaseResourcesCollectionViewController.h"
#import "JMConstants.h"

static NSString * kJMResourceCellIdentifier = @"ResourceCell";
static NSString * kJMLoadingCellIdentifier = @"LoadingCell";
static NSInteger const kJMPaginationTreshoald = 8;

@interface JMBaseResourcesCollectionViewController ()
@property (nonatomic, assign) UIInterfaceOrientation toInterfaceOrientation;
@end

@implementation JMBaseResourcesCollectionViewController

@synthesize needsToResetScroll = _needsToResetScroll;

- (BOOL)isLoadingCell:(UICollectionViewCell *)cell
{
    return [cell.reuseIdentifier isEqualToString:kJMLoadingCellIdentifier];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.toInterfaceOrientation = self.interfaceOrientation;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.toInterfaceOrientation = toInterfaceOrientation;
    if ([self respondsToSelector:@selector(collectionViewLayout)]) {
        [self.collectionViewLayout invalidateLayout];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reset scroll position for a new resources type
    if (self.needsToResetScroll) {
        self.collectionView.contentOffset = CGPointZero;

    // Or scroll to first visible resource
    } else if (self.delegate.firstVisibleResourceIndex > 1) {
        NSIndexPath *firstVisible = [NSIndexPath indexPathForItem:self.delegate.firstVisibleResourceIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:firstVisible atScrollPosition:self.scrollPosition animated:NO];

        if (self.yLandscapeOffset || self.yPortraitOffset) {
            // Adjust offset after scrolling
            CGFloat offset = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? self.yLandscapeOffset : self.yPortraitOffset;
            self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y - offset);
        }
    }
}

#pragma mark - UICollectionViewControllerDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.delegate.resources.count;
    if ([self.delegate hasNextPage]) count++;

    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.delegate.resources.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];

        // TODO: Set translated text
        // TODO: transform (or create custom) activity indicator

        return cell;
    }

    // TODO: make separate class for UICollectionViewCell (i.e. JMResourcesCollectionViewCell). Try to reuse it for "Grid" and "Horizontal List" views
    return [collectionView dequeueReusableCellWithReuseIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat inset;
    if (UIInterfaceOrientationIsLandscape(self.toInterfaceOrientation)) {
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoadNextPageNotification object:nil];
    }
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
