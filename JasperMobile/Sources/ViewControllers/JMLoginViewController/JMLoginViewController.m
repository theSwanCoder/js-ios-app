/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
#import "JMMenuViewController.h"

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
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] loginViewBackgroundColor];
    self.placeHolderView.backgroundColor = [[JMThemesManager sharedManager] loginViewPlaceholderBackgroundColor];
    [self.textfields makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[[JMThemesManager sharedManager] loginViewTextFieldsBackgroundColor]];
    [self.textfields makeObjectsPerformSelector:@selector(setFont:) withObject:[[JMThemesManager sharedManager] loginInputControlsFont]];

    UIColor *placeholderColor = [[JMThemesManager sharedManager] loginViewTextFieldsTextColor];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[placeholderColor colorWithAlphaComponent: 0.5f]};
    self.userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMCustomLocalizedString(@"login.username.label", nil) attributes:attributes];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMCustomLocalizedString(@"login.password.label", nil) attributes:attributes];
    self.serverProfileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMCustomLocalizedString(@"settings.item.server", nil) attributes:attributes];

    // setup "Login" button
    self.loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.tryDemoButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.loginButton.backgroundColor = [[JMThemesManager sharedManager] loginViewLoginButtonBackgroundColor];
    [self.loginButton setTitleColor:[[JMThemesManager sharedManager] loginViewLoginButtonTextColor] forState:UIControlStateNormal];
    [self.loginButton setTitle:JMCustomLocalizedString(@"login.button.login", nil) forState:UIControlStateNormal];
    
    [self.tryDemoButton setTitle:JMCustomLocalizedString(@"login.button.try.demo", nil) forState:UIControlStateNormal];

    if (self.showForRestoreSession) {
        // setup previous session
        self.userNameTextField.text = self.restClient.serverProfile.username;
        self.selectedServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
        self.tryDemoButton.enabled = NO;
        self.tryDemoButton.backgroundColor = [[JMThemesManager sharedManager] loginViewTryDemoButtonDisabledBackgroundColor];
        [self.tryDemoButton setTitleColor:[[JMThemesManager sharedManager] loginViewTryDemoDisabledButtonTextColor] forState:UIControlStateNormal];
    } else {
        self.tryDemoButton.backgroundColor = [[JMThemesManager sharedManager] loginViewTryDemoButtonBackgroundColor];
        [self.tryDemoButton setTitleColor:[[JMThemesManager sharedManager] loginViewTryDemoButtonTextColor] forState:UIControlStateNormal];
    }
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
        NSError *error = [NSError errorWithDomain:@"dialod.title.error" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error completion:nil];
    } else {

        [self loginWithServerProfile:self.selectedServerProfile userName:self.userNameTextField.text password:self.passwordTextField.text];
    }
}

- (IBAction)tryDemoButtonTapped:(id)sender
{
    [self loginWithServerProfile:[JMServerProfile demoServerProfile] userName:kJMDemoServerUsername password:kJMDemoServerPassword];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.showForRestoreSession) {
        if (textField == self.serverProfileTextField || textField == self.userNameTextField) {
            return NO;
        }
    }

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
    return ![JMUtils isCompactWidth];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [JMUtils isCompactWidth] ? UIInterfaceOrientationPortrait : [super preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [JMUtils isCompactWidth] ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}


#pragma mark - Private
- (void)loginWithServerProfile:(JMServerProfile *)serverProfile userName:(NSString *)username password:(NSString *)password
{
    JSProfile *jsServerProfile = [[JSProfile alloc] initWithAlias:serverProfile.alias
                                                        serverUrl:serverProfile.serverUrl
                                                     organization:serverProfile.organization
                                                         username:username
                                                         password:password];

    __weak typeof(self)weakSelf = self;
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^(void) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf.restClient cancelAllRequests];
    }];
    
    [[JMSessionManager sharedManager] createSessionWithServerProfile:jsServerProfile keepLogged:[serverProfile.keepSession boolValue] completion:^(NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [JMCancelRequestPopup dismiss];
        // Analytics
        [JMUtils logLoginSuccess:!error
                    additionInfo:@{
                                   kJMAnalyticsCategoryKey      : kJMAnalyticsAuthenticationEventCategoryTitle,
                                   kJMAnalyticsActionKey        : kJMAnalyticsAuthenticationEventActionLoginTitle,
                                   kJMAnalyticsLabelKey         : kJMAnalyticsAuthenticationEventLabelSuccess
                                   }];
        
        if (!error) {
            [strongSelf dismissViewControllerAnimated:NO completion:nil];
            if (strongSelf.completion) {
                strongSelf.completion();
            }
        } else {
            if ([error.domain isEqualToString:JSAuthErrorDomain]) {
                NSString *errorTitle = JMCustomLocalizedString(@"error.authenication.dialog.title", nil);
                NSString *errorMessage = JMCustomLocalizedString(@"error.authenication.dialog.msg", nil);
                error = [NSError errorWithDomain:errorTitle code:JSInvalidCredentialsErrorCode userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            }
            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
    }];
}

@end
