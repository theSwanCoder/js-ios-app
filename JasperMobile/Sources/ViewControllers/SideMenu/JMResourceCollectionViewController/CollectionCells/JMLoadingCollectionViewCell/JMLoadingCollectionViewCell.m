/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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


#import "JMLoadingCollectionViewCell.h"
#import "JMThemesManager.h"
#import "JMLocalization.h"
#import "NSObject+Additions.h"
#import "JMConstants.h"

NSString * kJMListLoadingCell = @"JMListLoadingCollectionViewCell";
NSString * kJMGridLoadingCell = @"JMGridLoadingCollectionViewCell";

@interface JMLoadingCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation JMLoadingCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] collectionLoadingFont];
    self.titleLabel.text = JMLocalizedString(@"resources_loading_msg");
    self.titleLabel.textColor = [[JMThemesManager sharedManager] resourceViewLoadingCellTitleTextColor];
    self.activityIndicator.color = [[JMThemesManager sharedManager] resourceViewLoadingCellActivityIndicatorColor];
}

@end
