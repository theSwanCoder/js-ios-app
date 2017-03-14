/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMMainNavigationController.h"

@interface JMMainNavigationController () <UINavigationControllerDelegate>

@end

@implementation JMMainNavigationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    
    self.navigationBar.opaque = YES;
    self.navigationBar.translucent = NO;
    self.toolbar.translucent = NO;
    self.interactivePopGestureRecognizer.enabled = NO;

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - AutoRotation
- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
