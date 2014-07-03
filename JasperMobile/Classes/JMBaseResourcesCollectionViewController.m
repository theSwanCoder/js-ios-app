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

static NSString * kJMResourceCellIdentifier = @"ResourceCell";
static NSString * kJMLoadingCellIdentifier = @"LoadingCell";

static NSInteger const kJMPaginationTreshoald = 8;

@implementation JMBaseResourcesCollectionViewController
objection_requires(@"constants")

@synthesize needsToResetScroll = _needsToResetScroll;

#pragma mark - Accessors

- (BOOL)isLoadingCell:(UICollectionViewCell *)cell
{
    return [cell.reuseIdentifier isEqualToString:kJMLoadingCellIdentifier];
}

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
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSInteger row;
    
    if ([self isReportSegue:segue]) {
        JSResourceLookup *resourcesLookup = [sender objectForKey:kJMResourceLookup];
        row = [self.delegate.resources indexOfObject:resourcesLookup];
    } else {
        row = [[self.collectionView indexPathForCell:sender] row];
    }
    
    NSDictionary *userInfo = @{
               kJMResources : self.delegate.resources,
               kJMTotalCount : @(self.delegate.totalCount),
               kJMOffset : @(self.delegate.offset),
               kJMSelectedResourceIndex : @(row)
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMShowResourcesListInMaster
                                                        object:nil
                                                      userInfo:userInfo];
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
    JSResourceLookup *resourceLookup = [self.delegate.resources objectAtIndex:indexPath.row];
    if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        [self fetchInputControlsForReport:resourceLookup];
    } else {
        NSDictionary *data = @{
                   kJMResourceLookup : resourceLookup
        };
        [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:data];
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

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    return [self.delegate actionBar];
}

@end
