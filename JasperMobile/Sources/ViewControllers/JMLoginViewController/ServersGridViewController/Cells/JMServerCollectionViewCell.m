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


#import "JMServerCollectionViewCell.h"
#import "JMServerProfile+Helpers.h"

@interface JMServerCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

@implementation JMServerCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] collectionResourceNameFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] serverProfileTitleTextColor];
    self.urlLabel.font = [[JMThemesManager sharedManager] collectionResourceDescriptionFont];
    self.urlLabel.textColor = [[JMThemesManager sharedManager] serverProfileDetailsTextColor];
    
    self.titleImage.backgroundColor = [[JMThemesManager sharedManager] serverProfilePreviewBackgroundColor];
    [self setAccessibility:YES withTextKey:nil identifier:JMServerProfilesPageServerCellAccessibilityId];
}

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    _serverProfile = serverProfile;
    self.titleLabel.text = serverProfile.alias;
    self.urlLabel.text = serverProfile.serverUrl;
    self.accessibilityLabel = serverProfile.serverUrl;
    self.accessibilityLanguage = JMPreferredLanguage;
}

- (void) cloneServerProfile:(id)sender
{
    [self.delegate cloneServerProfileForCell:self];
}

- (void) deleteServerProfile:(id)sender
{
    [self.delegate deleteServerProfileForCell:self];
}

- (void) editServerProfile:(id)sender
{
    [self.delegate editServerProfileForCell:self];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(cloneServerProfile:) || action == @selector(deleteServerProfile:) || action == @selector(editServerProfile:);
}
@end
