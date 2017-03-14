/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMLoadingCollectionViewCell.h"
#import "JMThemesManager.h"
#import "JMLocalization.h"

NSString * kJMHorizontalLoadingCell = @"JMHorizontalLoadingCollectionViewCell";
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
