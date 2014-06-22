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
//  JMHorizontalListViewController.m
//  Jaspersoft Corporation
//

#import "JMHorizontalListViewController.h"

@implementation JMHorizontalListViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesLandscapeInset = 30.0f;
    self.edgesPortraitInset = 30.0f;

}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if (!self.delegate.resources.count || [self isLoadingCell:cell]) return cell;

    JSResourceLookup *lookup = [self.delegate.resources objectAtIndex:indexPath.row];
    
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

@end
