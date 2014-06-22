//
//  JMGridViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 4/30/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMGridViewController.h"

@interface JMGridViewController()
@property (nonatomic, assign) UIInterfaceOrientation toInterfaceOrientation;
@end

@implementation JMGridViewController

@synthesize needsToResetScroll = _needsToResetScroll;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.yLandscapeOffset = 18.0f;
    self.yPortraitOffset = 17.0f;
    self.edgesLandscapeInset = 19.0f;
    self.edgesPortraitInset = 30.0f;
    self.scrollPosition = UICollectionViewScrollPositionTop;
}

#pragma mark - UICollectionViewControllerDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if (!self.delegate.resources.count || [self isLoadingCell:cell]) return cell;

    JSResourceLookup *lookup = [self.delegate.resources objectAtIndex:indexPath.row];
    UILabel *resourceLabel = (UILabel *) [cell viewWithTag:1];
    CGSize labelSize = [lookup.label sizeWithFont:resourceLabel.font constrainedToSize:CGSizeMake(236, 51) lineBreakMode:NSLineBreakByWordWrapping];
    resourceLabel.frame = CGRectMake(resourceLabel.frame.origin.x, resourceLabel.frame.origin.y, labelSize.width, labelSize.height);
    resourceLabel.text = lookup.label;

    return cell;
}

@end
