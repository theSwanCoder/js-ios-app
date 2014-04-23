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
//  JMHomeCollectionViewController.m
//  Jaspersoft Corporation
//

#import "JMHomeCollectionViewController.h"
#import "JMLocalization.h"

static NSString * const kJMMenuItemIdentifier = @"MenuItem";
static NSString * const kJMMenuItemLocalizationPrefix = @"home.menuitem";

@interface JMHomeCollectionViewController ()
@property (nonatomic, assign) UIInterfaceOrientation toInterfaceOrientation;
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation JMHomeCollectionViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check if iOS 7 or higher
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.collectionView.contentInset = UIEdgeInsetsMake(20.0f, 0, 0, 0);
    }

    self.menuItems = JMMenuItemArray;
    self.toInterfaceOrientation = self.interfaceOrientation;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(NSInteger)numberOfSectionsInCollectionView :(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JMMenuItemCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kJMMenuItemIdentifier forIndexPath:indexPath];
    NSString *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    // TODO: select right font for iOS 6 because it's missing "Apple SD Gothic Neo" one
    cell.label.text = JMCustomLocalizedString([NSString stringWithFormat:@"%@.%@.label", kJMMenuItemLocalizationPrefix, menuItem], nil);
    cell.desc.text = JMCustomLocalizedString([NSString stringWithFormat:@"%@.%@.description", kJMMenuItemLocalizationPrefix, menuItem], nil);
    [cell.desc sizeToFit];
    cell.imageView.image = [UIImage imageNamed:menuItem];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        return [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    }

    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate setSelectedItem:(JMMenuItem) indexPath.row];
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (UIInterfaceOrientationIsLandscape(self.toInterfaceOrientation)) {
        return UIEdgeInsetsMake(30.0f, 23.0f, 30.0f, 23.0f);
    } else {
        return UIEdgeInsetsMake(10.0f, 66.0f, 0.0f, 66.0f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return UIInterfaceOrientationIsLandscape(self.toInterfaceOrientation) ? 20.0f : 11.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return UIInterfaceOrientationIsLandscape(self.toInterfaceOrientation) ? 20.0f : 11.0f;
}

@end

@implementation JMMenuItemCell
@end
