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
#import "JMMenuItemCell.h"
#import "JMLocalization.h"
#import "JMServerProfile+Helpers.h"
#import "JMCustomSplitViewController.h"

// Localization keys defined as lowercase version of MenuItem identifier (e.g library, saveditems etc)
static NSString * const kJMMenuItemLibrary = @"Library";
static NSString * const kJMMenuItemSavedItems = @"SavedItems";
static NSString * const kJMMenuItemSettings = @"Settings";
static NSString * const kJMMenuItemRepository = @"Repository";
static NSString * const kJMMenuItemFavorites = @"Favorites";
static NSString * const kJMMenuItemServers = @"Servers";

static NSString * const kJMMenuItemIdentifier = @"MenuItem";

@interface JMHomeCollectionViewController () {
    NSArray *_portraitMenuItems;
    NSArray *_landscapeMenuItems;
}
- (NSArray *)menuItems;
@end

@implementation JMHomeCollectionViewController

#pragma mark - Accessors

- (NSArray *)menuItems
{
    return UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? _portraitMenuItems : _landscapeMenuItems;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Check if iOS 6 or earlier
    if (![self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.collectionView.contentInset = UIEdgeInsetsMake(-20.0f, 0, 0, 0);
    }

    _portraitMenuItems = @[
            kJMMenuItemLibrary,
            kJMMenuItemSavedItems,
            kJMMenuItemRepository,
            kJMMenuItemFavorites,
            kJMMenuItemSettings,
            kJMMenuItemServers
    ];
    
    _landscapeMenuItems = @[
            kJMMenuItemLibrary,
            kJMMenuItemSavedItems,
            kJMMenuItemSettings,
            kJMMenuItemRepository,
            kJMMenuItemFavorites,
            kJMMenuItemServers
    ];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Will force to load destination's view
    [segue.destinationViewController view];
    [segue.destinationViewController setMenuTitle:sender];
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
    NSString *menuItem = [[self.menuItems objectAtIndex:indexPath.row] lowercaseString];
    
    cell.imageView.image = [UIImage imageNamed:menuItem];
    cell.label.text = JMCustomLocalizedString([NSString stringWithFormat:@"home.menuitem.%@.label", menuItem], nil);
    cell.desc.text = JMCustomLocalizedString([NSString stringWithFormat:@"home.menuitem.%@.description", menuItem], nil);
    [cell.desc sizeToFit];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        UILabel *serverLabel = (UILabel *) [headerView viewWithTag:1];
        
        JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
        if (activeServerProfile) {
            NSString *format = JMCustomLocalizedString(@"home.menuitem.activeserver.label" , nil);
            serverLabel.hidden = NO;
            serverLabel.text = [NSString stringWithFormat:format, activeServerProfile.alias];
        }
        
        return headerView;
    }

    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:[NSString stringWithFormat:@"Show%@", menuItem] sender:menuItem];
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        return UIEdgeInsetsMake(30.0f, 23.0f, 30.0f, 23.0f);
    } else {
        return UIEdgeInsetsMake(10.0f, 66.0f, 0.0f, 66.0f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 20.0f : 11.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 20.0f : 11.0f;
}

@end
