/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMRevealViewController.h"

@interface JMRevealViewController ()

@end

@implementation JMRevealViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.rearViewRevealOverdraw = 0.f;
}

#pragma mark - AutoRotation
- (BOOL)shouldAutorotate
{
    return [self.frontViewController shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.frontViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.frontViewController preferredInterfaceOrientationForPresentation];
}
@end
