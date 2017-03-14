/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMBaseResourceView.h"
#import "JMThemesManager.h"
#import "JMUtils.h"

@implementation JMBaseResourceView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.topView.backgroundColor = [[JMThemesManager sharedManager] barsBackgroundColor];
    self.bottomView.backgroundColor = [[JMThemesManager sharedManager] barsBackgroundColor];
}

@end

NSString *const JMResourceContentViewDidMoveToSuperViewNotification = @"JMResourceContentViewDidMoveToSuperViewNotification";
NSString *const JMResourceContentViewDidLayoutSubviewsNotification = @"JMResourceContentViewDidLayoutSubviewsNotification";

@implementation JMResourceContentView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [[NSNotificationCenter defaultCenter] postNotificationName:JMResourceContentViewDidLayoutSubviewsNotification
                                                        object:self];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:JMResourceContentViewDidMoveToSuperViewNotification
                                                        object:self];
}

@end
