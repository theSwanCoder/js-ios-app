/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMServerCollectionViewCell.h"
#import "JMServerProfile+Helpers.h"
#import "JMThemesManager.h"

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
}

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    _serverProfile = serverProfile;
    self.titleLabel.text = serverProfile.alias;
    self.urlLabel.text = serverProfile.serverUrl;
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
