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


//
//  JMLoginViewController.h
//  TIBCO JasperMobile
//

#import "JMLoginViewController.h"
#import "JMServersGridViewController.h"
#import "JMServerProfile+Helpers.h"
#import "JasperMobileAppDelegate.h"
#import "JMSessionManager.h"
#import "JMCancelRequestPopup.h"
#import "JasperMobileAppDelegate.h"

@interface JMLoginViewController () <UITextFieldDelegate, JMServersGridViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverProfileTextField;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textfields;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;
@property (weak, nonatomic) IBOutlet UIButton *tryDemoButton;

@property (strong, nonatomic) JMServerProfile *selectedServerProfile;
@end

@implementation JMLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];
    self.placeHolderView.backgroundColor = kJMMainNavigationBarBackgroundColor;
    [self.textfields makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:kJMSearchBarBackgroundColor];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:kJMDetailViewLightTextColor};
    self.userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMCustomLocalizedString(@"login.username.label", nil) attributes:attributes];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMCustomLocalizedString(@"login.password.label", nil) attributes:attributes];
    self.serverProfileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMCustomLocalizedString(@"settings.item.server", nil) attributes:attributes];

    // setup "Login" button
    self.loginButton.backgroundColor = kJMResourcePreviewBackgroundColor;
    [self.loginButton setTitle:JMCustomLocalizedString(@"login.button.login", nil) forState:UIControlStateNormal];
    
    [self.tryDemoButton setTitleColor:kJMDetailViewLightTextColor forState:UIControlStateNormal];
    [self.tryDemoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    [self.tryDemoButton setTitle:JMCustomLocalizedString(@"login.button.try.demo", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textfields makeObjectsPerformSelector:@selector(resignFirstResponder)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showServerProfiles"]) {
        JMServersGridViewController *serversGridController = (JMServersGridViewController *)segue.destinationViewController;
        serversGridController.delegate = self;
    }
}

#pragma mark - Properties
- (void)setSelectedServerProfile:(JMServerProfile *)selectedServerProfile
{
    _selectedServerProfile = selectedServerProfile;
    self.serverProfileTextField.text = self.selectedServerProfile.alias;
}

#pragma mark - Actions
- (IBAction)loginButtonTapped:(id)sender
{
    NSMutableString *errorMessage = [NSMutableString string];
    if (![self.userNameTextField.text length]) {
        [errorMessage appendString:JMCustomLocalizedString(@"login.username.errmsg.empty", nil)];
    }
    if (![self.passwordTextField.text length]) {
        if ([errorMessage length]) {
            [errorMessage appendString:@"\n"];
        }
        [errorMessage appendString:JMCustomLocalizedString(@"login.password.errmsg.empty", nil)];
    }
    if (!self.selectedServerProfile) {
        if ([errorMessage length]) {
            [errorMessage appendString:@"\n"];
        }
        [errorMessage appendString:JMCustomLocalizedString(@"login.server.profile.errmsg.empty", nil)];
    }
    
    if ([errorMessage length]) {
        [[UIAlertView localizedAlertWithTitle:nil
                                      message:errorMessage
                                     delegate: nil
                            cancelButtonTitle:@"dialog.button.ok"
                            otherButtonTitles:nil] show];
    } else {

        [self loginWithServerProfile:self.selectedServerProfile userName:self.userNameTextField.text password:self.passwordTextField.text];
    }
}

- (IBAction)tryDemoButtonTapped:(id)sender
{
    [self loginWithServerProfile:[JMServerProfile demoServerProfile] userName:@"phoneuser" password:@"phoneuser"];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.serverProfileTextField) {
        self.selectedServerProfile = nil;
        [self performSegueWithIdentifier:@"showServerProfiles" sender:nil];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

#pragma mark - JMServersGridViewController
- (void)serverGridControllerDidSelectProfile:(JMServerProfile *)serverProfile
{
    self.selectedServerProfile = serverProfile;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Autorotation
- (BOOL)shouldAutorotate
{
    return ![JMUtils isIphone];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [JMUtils isIphone] ? UIInterfaceOrientationPortrait : [super preferredInterfaceOrientationForPresentation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [JMUtils isIphone] ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}


#pragma mark - Private
- (void)loginWithServerProfile:(JMServerProfile *)serverProfile userName:(NSString *)username password:(NSString *)password
{
    JSProfile *jsServerProfile = [[JSProfile alloc] initWithAlias:serverProfile.alias
                                                        serverUrl:serverProfile.serverUrl
                                                     organization:serverProfile.organization
                                                         username:username
                                                         password:password];

    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self.restClient cancelAllRequests];
    } @weakselfend];
    
    [[JMSessionManager sharedManager] createSessionWithServerProfile:jsServerProfile keepLogged:[serverProfile.keepSession boolValue] completion:@weakself(^(BOOL success)) {
        [JMCancelRequestPopup dismiss];
        if (success) {
            self.restClient.timeoutInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kJMDefaultRequestTimeout] ?: 120;
            if (self.completion) {
                self.completion();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoginDidSuccessNotification object:nil];
            [self dismissViewControllerAnimated:NO completion:@weakself(^(void)) {
                [self showOnboardIntro];
            } @weakselfend];
        } else {
            [[UIAlertView localizedAlertWithTitle:@"error.authenication.dialog.title"
                                          message:@"error.authenication.dialog.msg"
                                         delegate: nil
                                cancelButtonTitle:@"dialog.button.ok"
                                otherButtonTitles:nil] show];
        }
    } @weakselfend];
}

- (void)showOnboardIntro
{
    JasperMobileAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    if (appDelegate.isApplicationFirstStart) {
        SWRevealViewController *revealViewController = (SWRevealViewController *) appDelegate.window.rootViewController;
        UIViewController *introViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMOnboardIntroViewController"];
        [revealViewController.rearViewController presentViewController:introViewController animated:YES completion:nil];
    }
}
@end
