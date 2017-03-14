/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerShareManager.h"
#import "JMShareViewController.h"
#import "UIView+Additions.h"
#import "JMUtils.h"

@implementation JMResourceViewerShareManager

#pragma mark - Public API

- (void)shareContentView:(UIView *)contentView
{
    JMShareViewController *shareViewController = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMShareViewController"];
    shareViewController.imageForSharing = [contentView renderedImage];
    [self.controller.navigationController pushViewController:shareViewController animated:YES];
}

@end
