//
//  JMGridViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 4/30/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMGridViewController.h"
#import "JMConstants.h"

static NSString * kJMResourceCellIdentifier = @"ResourceCell";
static NSString * kJMLoadingCellIdentifier = @"LoadingCell";
static NSInteger const kJMPaginationTreshoald = 8;

@interface JMGridViewController()
@property (nonatomic, assign) UIInterfaceOrientation toInterfaceOrientation;
@end

@implementation JMGridViewController

@synthesize needsToResetScroll = _needsToResetScroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.toInterfaceOrientation = self.interfaceOrientation;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // TODO: implement scroll position saving for grid view
    NSArray *indexPaths = self.collectionView.indexPathsForVisibleItems;
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    self.delegate.firstVisibleResourceIndex = [(NSIndexPath *)sortedIndexPaths.firstObject item];
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

    // TODO: figure out what to do with scroll position in grid view...
    // Reset scroll position for a new resources type
    if (self.needsToResetScroll) {
        self.collectionView.contentOffset = CGPointZero;
        // Or scroll to first visible resource after switching list representation
    } else if (self.delegate.firstVisibleResourceIndex > 1) {
        NSIndexPath *firstVisible = [NSIndexPath indexPathForItem:self.delegate.firstVisibleResourceIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:firstVisible atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        CGFloat inset = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 18.0f : 17.0f;
        self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y - inset);
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
    UICollectionViewCell *cell;

    if (indexPath.item == self.delegate.resources.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMLoadingCellIdentifier forIndexPath:indexPath];

        // TODO: Set translated text
        // TODO: transform (or create custom) activity indicator

        return cell;
    }

    // TODO: make separate class for UICollectionViewCell (i.e. JMResourcesCollectionViewCell). Try to reuse it for "Grid" and "Horizontal List" views
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMResourceCellIdentifier forIndexPath:indexPath];

    // Preventing NPE because "delegate.resources" is a weak reference
    if (!self.delegate.resources.count) return cell;

    JSResourceLookup *lookup = [self.delegate.resources objectAtIndex:indexPath.row];

    UILabel *resourceLabel = (UILabel *) [cell viewWithTag:1];
    CGSize labelSize = [lookup.label sizeWithFont:resourceLabel.font constrainedToSize:CGSizeMake(236, 51) lineBreakMode:NSLineBreakByWordWrapping];
    resourceLabel.frame = CGRectMake(resourceLabel.frame.origin.x, resourceLabel.frame.origin.y, labelSize.width, labelSize.height);
    resourceLabel.text = lookup.label;

    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat inset;
    if (UIInterfaceOrientationIsLandscape(self.toInterfaceOrientation)) {
        inset = 19.0f;
    } else {
        inset = 30.0f;
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
    [self.collectionView reloadData];
}

@end
