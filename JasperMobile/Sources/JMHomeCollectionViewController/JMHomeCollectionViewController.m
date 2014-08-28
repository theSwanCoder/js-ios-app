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
#import "JMServerProfile+Helpers.h"

// Localization keys defined as lowercase version of MenuItem identifier (e.g library, saveditems etc)
static NSString * const kJMMenuItemLibrary = @"Library";
static NSString * const kJMMenuItemSettings = @"Settings";
static NSString * const kJMMenuItemRepository = @"Repository";

static NSString * const kJMMenuItemIdentifier = @"MenuItem";

@interface JMHomeCollectionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *activeServerView;
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation JMHomeCollectionViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuItems = @[
            kJMMenuItemLibrary,
            kJMMenuItemRepository,
            kJMMenuItemSettings
    ];
    
    self.title = JMCustomLocalizedString(@"title.home", nil);
    
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSString *serverString = nil;
    if (activeServerProfile) {
        serverString = activeServerProfile.alias;
    } 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:serverString style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.collectionView.backgroundColor = kJMMainCollectionViewBackgroundColor;
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
    [segue.destinationViewController setTitle:sender];
}

#pragma mark - UICollectionViewDataSource

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

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:[NSString stringWithFormat:@"Show%@", menuItem] sender:menuItem];
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    
    NSInteger countOfCellsInRow = 1;
    while (((countOfCellsInRow * flowLayout.itemSize.width) + (countOfCellsInRow + 1) * flowLayout.minimumInteritemSpacing) < collectionView.frame.size.width) {
        countOfCellsInRow ++;
    }
    countOfCellsInRow --;
    
    CGFloat horizontalInset = floor((collectionView.frame.size.width - countOfCellsInRow * flowLayout.itemSize.width) / (countOfCellsInRow + 1));
    UIEdgeInsets insets = UIEdgeInsetsMake(flowLayout.sectionInset.top, horizontalInset, flowLayout.sectionInset.bottom, horizontalInset);
    
    return insets;
}

@end
