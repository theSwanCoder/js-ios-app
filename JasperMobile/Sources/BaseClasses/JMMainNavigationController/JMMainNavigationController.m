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


#import "JMMainNavigationController.h"

@interface JMMainNavigationController () <UINavigationControllerDelegate>

@end

@implementation JMMainNavigationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
    [[UINavigationBar appearance] setBarTintColor: kJMMainNavigationBarBackgroundColor];
    [[UIToolbar appearance] setBarTintColor: kJMMainNavigationBarBackgroundColor];

    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightTextColor]}];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.toolbar setTintColor: [UIColor whiteColor]];

    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [JMFont navigationBarTitleFont], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    
    if ([UIDevice currentDevice].systemVersion.integerValue <8) {
        // Here is hack for using UIPrintInteractionController
        NSDictionary *textTitleOptionsForPopover = [NSDictionary dictionaryWithObjectsAndKeys:kJMMainNavigationBarBackgroundColor, NSForegroundColorAttributeName, [JMFont navigationBarTitleFont], NSFontAttributeName, nil];
        [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:textTitleOptionsForPopover];
    }

    NSDictionary *barButtonTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName, [JMFont navigationItemsFont], NSFontAttributeName, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateNormal];
    
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    
    self.navigationBar.opaque = YES;
    self.navigationBar.translucent = NO;
    self.toolbar.translucent = NO;
    self.interactivePopGestureRecognizer.enabled = NO;
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

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
