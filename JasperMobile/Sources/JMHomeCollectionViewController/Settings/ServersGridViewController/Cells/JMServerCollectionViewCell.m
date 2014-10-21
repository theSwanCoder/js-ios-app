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


#import "JMServerCollectionViewCell.h"
#import "JMServerProfile+Helpers.h"


@interface JMServerCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;

@end

@implementation JMServerCollectionViewCell

- (void)awakeFromNib
{
    self.activeLabel.text = JMCustomLocalizedString(@"servers.gridview.activeserver.label", nil);
}

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    _serverProfile = serverProfile;
    self.titleLabel.text = serverProfile.alias;
    self.urlLabel.text = serverProfile.serverUrl;
    
    if ([serverProfile serverProfileIsActive]) {
        self.activeLabel.hidden = NO;
        self.titleImage.image = [UIImage imageNamed:@"server_active"];
    } else {
        self.activeLabel.hidden = YES;
        self.titleImage.image = [UIImage imageNamed:@"server"];
    }
}
@end
