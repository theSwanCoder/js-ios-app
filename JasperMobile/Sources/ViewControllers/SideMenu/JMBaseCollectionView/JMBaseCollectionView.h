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

/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.0
 */

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationType_HorizontalList = 0,
    JMResourcesRepresentationType_Grid = 1
};

static inline JMResourcesRepresentationType JMResourcesRepresentationTypeFirst() { return JMResourcesRepresentationType_HorizontalList; }
static inline JMResourcesRepresentationType JMResourcesRepresentationTypeLast() { return JMResourcesRepresentationType_Grid; }

@interface JMBaseCollectionView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UINavigationBar *searchBarPlaceholder;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *activityViewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noResultsViewTitleLabel;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)setup;
- (NSString *)loadingCellForRepresentationType:(JMResourcesRepresentationType)type;
- (NSString *)resourceCellForRepresentationType:(JMResourcesRepresentationType)type;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)showNoResultsView;
- (void)hideNoResultView;
@end
