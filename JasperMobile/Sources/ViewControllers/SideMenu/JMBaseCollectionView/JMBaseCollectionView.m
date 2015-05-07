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
//  JMBaseCollectionView.h
//  TIBCO JasperMobile
//

#import "JMBaseCollectionView.h"
#import "JMBaseCollectionViewController.h"
#import "JMResourceCollectionViewCell.h"
#import "JMLoadingCollectionViewCell.h"
#import "JMFont.h"
#import "JMLocalization.h"

@implementation JMBaseCollectionView

-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"JMBaseCollectionView" owner:self options:nil];
    [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview: self.contentView];
}

- (void)setup
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];
    
    self.activityViewTitleLabel.text = JMCustomLocalizedString(@"resources.loading.msg", nil);
    self.noResultsViewTitleLabel.text = JMCustomLocalizedString(@"resources.noresults.msg", nil);
    
    self.activityViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    self.noResultsViewTitleLabel.font = [JMFont resourcesActivityTitleFont];
    
    [self setupCollectionView];
}

#pragma mark - UICollectionView setup
- (void)setupCollectionView
{
    for (NSInteger i = JMResourcesRepresentationTypeFirst(); i <= JMResourcesRepresentationTypeLast(); i ++) {
        [self.collectionView registerNib:[UINib nibWithNibName:[self resourceCellForRepresentationType:i] bundle:nil]
              forCellWithReuseIdentifier:[self resourceCellForRepresentationType:i]];
        [self.collectionView registerNib:[UINib nibWithNibName:[self loadingCellForRepresentationType:i] bundle:nil]
              forCellWithReuseIdentifier:[self loadingCellForRepresentationType:i]];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:self.searchBarPlaceholder.bounds];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = JMCustomLocalizedString(@"resources.search.placeholder", nil);
    }
    return _searchBar;
}

#pragma mark - Utils
- (NSString *)resourceCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationType_HorizontalList:
            return kJMHorizontalResourceCell;
        case JMResourcesRepresentationType_Grid:
            return kJMGridResourceCell;
        default:
            return nil;
    }
}


- (NSString *)loadingCellForRepresentationType:(JMResourcesRepresentationType)type
{
    switch (type) {
        case JMResourcesRepresentationType_HorizontalList:
            return kJMHorizontalLoadingCell;
        case JMResourcesRepresentationType_Grid:
            return kJMGridLoadingCell;
        default:
            return nil;
    }
}

#pragma mark - Loading views
- (void)showLoadingView
{
    [self.collectionView reloadData];
    self.activityViewTitleLabel.hidden = NO;
    self.activityIndicator.hidden = NO;
    self.noResultsViewTitleLabel.hidden = YES;
    self.collectionView.hidden = YES;
}

- (void)hideLoadingView
{
    [self.collectionView reloadData];
    [self.refreshControl endRefreshing];

    self.activityViewTitleLabel.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.collectionView.hidden = NO;

    if ([self collectionViewNotEmpty]) {
        self.noResultsViewTitleLabel.hidden = YES;
    } else {
        self.noResultsViewTitleLabel.hidden = NO;
    }
}

- (BOOL) collectionViewNotEmpty
{
    NSInteger sectionsCount = self.collectionView.numberOfSections;
    if (sectionsCount) {
        NSInteger rowsCount = 0;
        for (NSInteger section = 0; section < sectionsCount; section ++) {
            rowsCount += [self.collectionView numberOfItemsInSection:section];
        }
        return (rowsCount > 0);
    }
    return NO;
}

@end