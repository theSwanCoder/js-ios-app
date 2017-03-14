/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMLoginViewController.h"
#import "JMServersGridViewController.h"
#import "JMServerProfile+Helpers.h"
#import "JasperMobileAppDelegate.h"
#import "JMSessionManager.h"
#import "JMCancelRequestPopup.h"
#import "JasperMobileAppDelegate.h"
#import "JMMenuViewController.h"
#import "JMAnalyticsManager.h"
#import "JMThemesManager.h"
#import "JMLocalization.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"
#import "JMConstants.h"
#import "JMCoreDataManager.h"
#import "JSUserProfile.h"

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
    self.userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMLocalizedString(@"login_username_label") attributes:attributes];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMLocalizedString(@"login_password_label") attributes:attributes];
    self.serverProfileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:JMLocalizedString(@"settings_item_server") attributes:attributes];

    // setup "Login" button
    self.loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.tryDemoButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.loginButton.backgroundColor = [[JMThemesManager sharedManager] loginViewLoginButtonBackgroundColor];
    [self.loginButton setTitleColor:[[JMThemesManager sharedManager] loginViewLoginButtonTextColor] forState:UIControlStateNormal];
    [self.loginButton setTitle:JMLocalizedString(@"login_button_login") forState:UIControlStateNormal];
    
    self.tryDemoButton.backgroundColor = [[JMThemesManager sharedManager] loginViewTryDemoButtonBackgroundColor];
    [self.tryDemoButton setTitleColor:[[JMThemesManager sharedManager] loginViewTryDemoButtonTextColor] forState:UIControlStateNormal];

    [self updateControlsForRestoration];
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

- (void) updateControlsForRestoration
{
    if (self.showForRestoreSession) {
        // setup previous session
        JSUserProfile *serverProfile = [JMSessionManager sharedManager].serverProfile;
        self.userNameTextField.text = serverProfile.username;
        self.selectedServerProfile = [JMUtils activeServerProfile];
;
    } else {
        if ([JMUtils isAutofillLoginDataEnable]) {
            NSString *lastUserName = [JMUtils lastUserName];
            JMServerProfile *lastServerProfile = [JMUtils lastServerProfile];

            self.userNameTextField.text = lastUserName;
            self.selectedServerProfile = lastServerProfile;
        } else {
            self.userNameTextField.text = nil;
            self.selectedServerProfile = nil;
        }
    }
    
    NSString *tryDemoButtonTitle = self.showForRestoreSession ? JMLocalizedString(@"dialog_button_cancel") : JMLocalizedString(@"login_button_try_demo");
    SEL tryDemoButtonAction = self.showForRestoreSession ? @selector(cancelButtonTapped:) : @selector(tryDemoButtonTapped:);
    
    [self.tryDemoButton setTitle:tryDemoButtonTitle forState:UIControlStateNormal];
    [self.tryDemoButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.tryDemoButton addTarget:self action:tryDemoButtonAction forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Properties
- (void)setShowForRestoreSession:(BOOL)showForRestoreSession
{
    if (showForRestoreSession != _showForRestoreSession) {
        _showForRestoreSession = showForRestoreSession;
        
        [self updateControlsForRestoration];
    }
}

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
        [errorMessage appendString:JMLocalizedString(@"login_username_errmsg_empty")];
    }
    if (![self.passwordTextField.text length]) {
        if ([errorMessage length]) {
            [errorMessage appendString:@"\n"];
        }
        [errorMessage appendString:JMLocalizedString(@"login_password_errmsg_empty")];
    }
    if (!self.selectedServerProfile) {
        if ([errorMessage length]) {
            [errorMessage appendString:@"\n"];
        }
        [errorMessage appendString:JMLocalizedString(@"login_server_profile_errmsg_empty")];
    }
    
    if ([errorMessage length]) {
        NSError *error = [NSError errorWithDomain:@"dialod_title_error" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error completion:nil];
    } else {
        [JMUtils saveLastUserName:self.userNameTextField.text];
        [JMUtils saveLastServerProfile:self.selectedServerProfile];
        [self loginWithServerProfile:self.selectedServerProfile userName:self.userNameTextField.text password:self.passwordTextField.text];
    }
}

- (void)cancelButtonTapped:(id)sender
{
    [[JMSessionManager sharedManager] logout];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:JMLoginVCLastUserNameKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:JMLoginVCLastServerProfileAliasKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.showForRestoreSession = NO;
}

- (void)tryDemoButtonTapped:(id)sender
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
    JSUserProfile *jsServerProfile = [[JSUserProfile alloc] initWithAlias:serverProfile.alias
                                                                serverUrl:serverProfile.serverUrl
                                                             organization:serverProfile.organization
                                                                 username:username
                                                                 password:password];
    jsServerProfile.keepSession = [serverProfile.keepSession boolValue];
    
    __weak typeof(self)weakSelf = self;
    [JMCancelRequestPopup presentWithMessage:@"status_loading" cancelBlock:^(void) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf.restClient cancelAllRequests];
    }];
    
    [[JMSessionManager sharedManager] createSessionWithServerProfile:jsServerProfile completion:^(NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [JMCancelRequestPopup dismiss];
        // Analytics
        [[JMAnalyticsManager sharedManager] sendAnalyticsEventAboutLoginSuccess:!error
                                                                   additionInfo:@{
                                                                                  kJMAnalyticsCategoryKey : kJMAnalyticsAuthenticationEventCategoryTitle,
                                                                                  kJMAnalyticsActionKey   : kJMAnalyticsAuthenticationEventActionLoginTitle,
                                                                                  kJMAnalyticsLabelKey    : kJMAnalyticsAuthenticationEventLabelSuccess
                                                                                  }];
        
        if (!error) {
            serverProfile.useVisualize = @([JMUtils isSupportVisualize]);
            [[JMCoreDataManager sharedInstance] save:nil];
            
            [strongSelf dismissViewControllerAnimated:NO completion:nil];
            if (strongSelf.completion) {
                strongSelf.completion();
            }
        } else {
            if ([error.domain isEqualToString:JSAuthErrorDomain]) {
                NSString *errorTitle = JMLocalizedString(@"error_authenication_dialog_title");
                NSString *errorMessage = JMLocalizedString(@"error_authenication_dialog_msg");
                error = [NSError errorWithDomain:errorTitle code:JSInvalidCredentialsErrorCode userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            }
            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
    }];
}

@end
