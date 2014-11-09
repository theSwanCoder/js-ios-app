/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  TIBCO JasperMobile
//

#import "JMHomeCollectionViewController.h"
#import "JMMenuItemCell.h"
#import "JMServerProfile+Helpers.h"
#import "JMResourcesCollectionViewController.h"

#import "ALToastView.h"
#import "JasperMobileAppDelegate.h"
#import "JMIntroViewController.h"
#import "UIView+Additions.h"

// Localization keys defined as lowercase version of MenuItem identifier (e.g library, saveditems etc)
static NSString * const kJMMenuItemLibrary = @"Library";
static NSString * const kJMMenuItemSettings = @"Settings";
static NSString * const kJMMenuItemRepository = @"Repository";
static NSString * const kJMMenuItemSavedItems = @"SavedItems";
static NSString * const kJMMenuItemFavorites = @"Favorites";

static NSString * const kJMMenuItemIdentifier = @"MenuItem";

@interface JMHomeCollectionViewController ()
@property (nonatomic, strong) UILabel *activeServerLabel;
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
            kJMMenuItemFavorites,
            kJMMenuItemSavedItems,
            kJMMenuItemSettings,
    ];
    
    self.title = JMCustomLocalizedString(@"title.home", nil);
    self.collectionView.backgroundColor = kJMMainCollectionViewBackgroundColor;

    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    if (activeServerProfile) {
        NSString *serverString = activeServerProfile.alias;
        CGFloat widthForLabel = [JMUtils isIphone] ? 105.f : 220.f;
        self.activeServerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, widthForLabel, 30)];
        self.activeServerLabel.numberOfLines = 1;
        self.activeServerLabel.textAlignment = NSTextAlignmentRight;
        self.activeServerLabel.text = serverString;
        self.activeServerLabel.font = [JMFont navigationItemsFont];
        self.activeServerLabel.adjustsFontSizeToFitWidth = NO;
        self.activeServerLabel.backgroundColor = [UIColor clearColor];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activeServerLabel];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:kJMChangeServerProfileNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakselfnotnil(^(NSNotification *notification)) {
        JMServerProfile *serverProfile = [[notification userInfo] objectForKey:kJMServerProfileKey];
        self.activeServerLabel.text = serverProfile.alias;
    } @weakselfend];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    JasperMobileAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.isApplicationFirstStart) {
        appDelegate.applicationFirstStart = NO;
        [self showIntroView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowIntroView"]) {
        JMIntroViewController *introViewController = segue.destinationViewController;
        introViewController.view.backgroundColor = [UIColor colorWithPatternImage:[self.view renderedImageForView:self.navigationController.view]];
    } else {
        id viewController = segue.destinationViewController;
        [viewController setTitle:sender];
        if ([viewController respondsToSelector:@selector(setPresentingType:)]) {
            [viewController setPresentingType:[self presentingTypeForSequeIdentifier:segue.identifier]];
        }
        if ([viewController respondsToSelector:@selector(setRepresentationType:)]) {
            [viewController setRepresentationType:JMResourcesRepresentationTypeHorizontalList];
        }
    }
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
    cell.coloredView.backgroundColor = [menuItem isEqualToString:[kJMMenuItemSettings lowercaseString]] ? kJMMasterResourceCellSelectedBackgroundColor : kJMResourcePreviewBackgroundColor;
    cell.imageView.image = [UIImage imageNamed:menuItem];
    cell.label.text = JMCustomLocalizedString([NSString stringWithFormat:@"home.menuitem.%@.label", menuItem], nil);
    cell.desc.text = JMCustomLocalizedString([NSString stringWithFormat:@"home.menuitem.%@.description", menuItem], nil);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:[NSString stringWithFormat:@"Show%@", menuItem] sender:JMCustomLocalizedString([[NSString stringWithFormat:@"home.menuitem.%@.label", menuItem] lowercaseString], nil)];
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    NSInteger countOfCellsInRow = 1;
    while (((countOfCellsInRow * flowLayout.itemSize.width) + (countOfCellsInRow + 1) * flowLayout.minimumInteritemSpacing) < collectionView.frame.size.width) {
        countOfCellsInRow ++;
    }
    countOfCellsInRow --;
    
    CGFloat width = floor((collectionView.frame.size.width - flowLayout.sectionInset.left * (countOfCellsInRow + 1)) / countOfCellsInRow);
    return CGSizeMake(width, flowLayout.itemSize.height);
}

- (JMResourcesCollectionViewControllerPresentingType)presentingTypeForSequeIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:[NSString stringWithFormat:@"Show%@", kJMMenuItemLibrary]]) {
        return JMResourcesCollectionViewControllerPresentingType_Library;
    } else if ([identifier isEqualToString:[NSString stringWithFormat:@"Show%@", kJMMenuItemRepository]]) {
        return JMResourcesCollectionViewControllerPresentingType_Repository;
    } else if ([identifier isEqualToString:[NSString stringWithFormat:@"Show%@", kJMMenuItemSavedItems]]) {
        return JMResourcesCollectionViewControllerPresentingType_SavedItems;
    } if ([identifier isEqualToString:[NSString stringWithFormat:@"Show%@", kJMMenuItemFavorites]]) {
        return JMResourcesCollectionViewControllerPresentingType_Favorites;
    }

    return 0;
}

#pragma mark - Intro View
- (void)showIntroView {
    [self performSegueWithIdentifier:@"ShowIntroView" sender:nil];
}

@end
