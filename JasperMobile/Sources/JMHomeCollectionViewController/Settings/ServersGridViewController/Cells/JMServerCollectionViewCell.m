//
//  JMServerCollectionViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/7/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

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
