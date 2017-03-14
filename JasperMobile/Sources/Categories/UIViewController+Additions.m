/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "UIViewController+Additions.h"

@implementation UIViewController(Additions)

- (BOOL)isVisible {
    //TODO: Here you can add UITabBarController support
    if (self.navigationController) {
        return self.navigationController.visibleViewController == self;
    }
    
    return [self isViewLoaded] && self.view.window;
}

@end
