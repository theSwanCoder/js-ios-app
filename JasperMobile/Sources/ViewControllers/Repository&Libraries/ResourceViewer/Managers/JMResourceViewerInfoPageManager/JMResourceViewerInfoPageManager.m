/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerInfoPageManager.h"
#import "JMResource.h"
#import "JMMainNavigationController.h"
#import "JMResourceInfoViewController.h"

@implementation JMResourceViewerInfoPageManager

#pragma mark - Public API
- (void)showInfoPageForResource:(JMResource *)resource
{
    JMResourceInfoViewController *vc = (JMResourceInfoViewController *) [NSClassFromString([resource infoVCIdentifier]) new];
    vc.resource = resource;
    JMMainNavigationController *nextNC = [[JMMainNavigationController alloc] initWithRootViewController:vc];

    nextNC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.controller.navigationController presentViewController:nextNC animated:YES completion:nil];
}

@end
