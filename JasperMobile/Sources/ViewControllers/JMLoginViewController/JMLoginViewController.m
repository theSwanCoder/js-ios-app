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
#import "JMServersView.h"
#import "JMServerView.h"
#import "JMLoginView.h"
#import "JMAddServerView.h"

@interface JMLoginViewController () <UITextFieldDelegate, JMServersGridViewControllerDelegate, JMServerViewDelegate>
//@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
//@property (weak, nonatomic) IBOutlet UITextField *serverProfileTextField;
//@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textfields;

//@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;
//@property (weak, nonatomic) IBOutlet UIButton *tryDemoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeholderViewCenterYConstraint;

@property (strong, nonatomic) JMServerProfile *selectedServerProfile;
// servers view
@property (weak, nonatomic) IBOutlet UIView *contentServersView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentServersViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentServersViewHeightConstraint;

// login view
@property (weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *organizationTextField;
@property (nonatomic, weak) JMLoginView *loginView;
@property (nonatomic, weak) NSLayoutConstraint *loginViewLeadingConstraint;
@property (nonatomic, weak) NSLayoutConstraint *loginViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLabelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordLabelCenterXConstraint;
@property (weak, nonatomic) IBOutlet UILabel *usernameErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationErrorLabel;

// new server view
@property (weak, nonatomic) IBOutlet UITextField *addServerAliasTextField;
@property (weak, nonatomic) IBOutlet UITextField *addServerURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *addServerOrganizationTextField;
@property (nonatomic, weak) JMAddServerView *addServerView;
@property (nonatomic, weak) NSLayoutConstraint *addServerViewTopConstraint;
@property (nonatomic, weak) NSLayoutConstraint *addServerViewBottomConstraint;
@end

@implementation JMLoginViewController

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[JMThemesManager sharedManager] loginViewBackgroundColor];
    self.placeHolderView.backgroundColor = [[JMThemesManager sharedManager] loginViewPlaceholderBackgroundColor];

    [self addServersView];
    [self addLoginView];
    [self addNewServerView];

    [self hideErrors];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(placeholderViewDidTouch:)];
    [self.placeHolderView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = ((NSValue *)userInfo[@"UIKeyboardFrameEndUserInfoKey"]).CGRectValue;
    CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
    self.placeholderViewCenterYConstraint.constant = -keyboardHeight + CGRectGetHeight(self.placeHolderView.frame) / 2;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.placeholderViewCenterYConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Show views
- (void)addServersView
{
    JMServersView *serversView = [[NSBundle mainBundle] loadNibNamed:@"JMServersView" owner:self options:nil].firstObject;
    [self.placeHolderView addSubview:serversView];

    self.contentServersViewHeightConstraint.constant = 90;
//    self.contentServersViewWidthConstraint.constant = CGRectGetWidth(self.view.frame) + 1500;

    CGFloat currentXPosition = 10;

    // add demo profile
    JMServerView *serverView = [[NSBundle mainBundle] loadNibNamed:@"JMServerView" owner:self options:nil].firstObject;
    CGRect serverViewFrame = serverView.frame;
    serverViewFrame.origin.x = currentXPosition;
    serverViewFrame.origin.y = 10;
    serverView.frame = serverViewFrame;
    serverView.title = @"Demo";
    serverView.identifier = 1;
    serverView.delegate = self;
    [self.contentServersView addSubview:serverView];

    // add existing server profiles
    for (JMServerProfile *serverProfile in [self allServerProfiles]) {
        currentXPosition += CGRectGetWidth(serverViewFrame) + 10;

        serverView = [[NSBundle mainBundle] loadNibNamed:@"JMServerView" owner:self options:nil].firstObject;
        serverViewFrame = serverView.frame;
        serverViewFrame.origin.x = currentXPosition;
        serverViewFrame.origin.y = 10;
        serverView.frame = serverViewFrame;
        serverView.title = serverProfile.alias;
        serverView.identifier = 2;
        serverView.delegate = self;
        [self.contentServersView addSubview:serverView];
    }

    // add button "+"
    currentXPosition += CGRectGetWidth(serverViewFrame) + 10;

    serverView = [[NSBundle mainBundle] loadNibNamed:@"JMServerView" owner:self options:nil].firstObject;
    serverViewFrame = serverView.frame;
    serverViewFrame.origin.x = currentXPosition;
    serverViewFrame.origin.y = 10;
    serverView.frame = serverViewFrame;
    serverView.title = @"+";
    serverView.identifier = 0;
    serverView.delegate = self;
    [self.contentServersView addSubview:serverView];

    self.contentServersViewWidthConstraint.constant = currentXPosition + CGRectGetWidth(serverViewFrame) + 10;

    // add constraints
    serversView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[serversView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"serversView": serversView}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[serversView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"serversView": serversView}]];
}

- (void)addLoginView
{
    JMLoginView *loginView = [[NSBundle mainBundle] loadNibNamed:@"JMLoginView" owner:self options:nil].firstObject;
    [self.placeHolderView addSubview:loginView];

    self.loginView = loginView;

    // add constraints
    loginView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:loginView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.placeHolderView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1
                                                                   constant:CGRectGetWidth(self.view.frame)];

    [self.view addConstraint:constraint];
    self.loginViewLeadingConstraint = constraint;

    constraint = [NSLayoutConstraint constraintWithItem:self.placeHolderView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:loginView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1
                                               constant:-CGRectGetWidth(self.view.frame)];
    [self.view addConstraint:constraint];
    self.loginViewTrailingConstraint = constraint;

    constraint = [NSLayoutConstraint constraintWithItem:loginView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.placeHolderView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:0];
    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self.placeHolderView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:loginView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                               constant:0];
    [self.view addConstraint:constraint];
}

- (void)addNewServerView
{
    JMAddServerView *newServerView = [[NSBundle mainBundle] loadNibNamed:@"JMAddServerView" owner:self options:nil].firstObject;
    [self.placeHolderView addSubview:newServerView];

    self.addServerView = newServerView;

    // add constraints
    newServerView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:newServerView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.placeHolderView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1
                                                                   constant:0];

    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self.placeHolderView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:newServerView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1
                                               constant:0];
    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:newServerView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.placeHolderView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:CGRectGetHeight(self.placeHolderView.frame)];
    [self.view addConstraint:constraint];
    self.addServerViewTopConstraint = constraint;

    constraint = [NSLayoutConstraint constraintWithItem:self.placeHolderView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:newServerView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                               constant:-CGRectGetHeight(self.placeHolderView.frame)];
    [self.view addConstraint:constraint];
    self.addServerViewBottomConstraint = constraint;
}

- (void)showLoginView
{
    self.loginViewLeadingConstraint.constant = 0;
    self.loginViewTrailingConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideLoginView
{
    self.loginViewLeadingConstraint.constant = CGRectGetWidth(self.view.frame);
    self.loginViewTrailingConstraint.constant = -CGRectGetWidth(self.view.frame);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showAddNewServerView
{
    self.addServerViewTopConstraint.constant = 0;
    self.addServerViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideAddNewServerView
{
    self.addServerViewTopConstraint.constant = CGRectGetHeight(self.placeHolderView.frame);
    self.addServerViewBottomConstraint.constant = -CGRectGetHeight(self.placeHolderView.frame);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showErrorUsernameNotValidWithMessage:(NSString *)message
{
    self.usernameErrorLabel.hidden = NO;
    self.usernameErrorLabel.text = message;

    [UIView animateKeyframesWithDuration:0.30 delay:0.0 options:0 animations:^{
        self.usernameLabelCenterXConstraint.constant = -10;
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.usernameLabelCenterXConstraint.constant = -5;
        [UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.20 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.usernameLabelCenterXConstraint.constant = -0;
        [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.usernameLabelCenterXConstraint.constant = -5;
        [UIView addKeyframeWithRelativeStartTime:0.50 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.usernameLabelCenterXConstraint.constant = -10;
        [UIView addKeyframeWithRelativeStartTime:0.65 relativeDuration:0.20 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.usernameLabelCenterXConstraint.constant = -5;
        [UIView addKeyframeWithRelativeStartTime:0.85 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];
    } completion:^(BOOL finished) {
        NSLog(@"Animation finished");
    }];
}

- (void)showErrorPasswordNotValidWithMessage:(NSString *)message
{
    self.passwordErrorLabel.hidden = NO;
    self.passwordErrorLabel.text = message;

    [UIView animateKeyframesWithDuration:0.30 delay:0.0 options:0 animations:^{
        self.passwordLabelCenterXConstraint.constant = -10;
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.passwordLabelCenterXConstraint.constant = -5;
        [UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.20 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.passwordLabelCenterXConstraint.constant = -0;
        [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.passwordLabelCenterXConstraint.constant = -5;
        [UIView addKeyframeWithRelativeStartTime:0.50 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.passwordLabelCenterXConstraint.constant = -10;
        [UIView addKeyframeWithRelativeStartTime:0.65 relativeDuration:0.20 animations:^{
            [self.view layoutIfNeeded];
        }];

        self.passwordLabelCenterXConstraint.constant = -5;
        [UIView addKeyframeWithRelativeStartTime:0.85 relativeDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];
    } completion:^(BOOL finished) {
        NSLog(@"Animation finished");
    }];
}

- (void)hideErrors
{
    self.usernameErrorLabel.hidden = YES;
    self.passwordErrorLabel.hidden = YES;
    self.organizationErrorLabel.hidden = YES;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showServerProfiles"]) {
        JMServersGridViewController *serversGridController = (JMServersGridViewController *)segue.destinationViewController;
        serversGridController.delegate = self;
    }
}

#pragma mark - Actions
- (IBAction)showServersView:(id)sender
{
    [self hideErrors];
    [self.view endEditing:YES];
    [self hideLoginView];
}

- (IBAction)loginAction:(id)sender
{
    JMLog(@"login");
    [self hideErrors];

    // validate username and password
    NSError *error;
    BOOL isUsernameValid = [self validateUsername:self.usernameTextField.text error:&error];
    if (!isUsernameValid) {
        // show error
        [self showErrorUsernameNotValidWithMessage:error.localizedDescription];
    }

    BOOL isPasswordValid = [self validatePassword:self.passwordTextField.text error:&error];
    if (!isPasswordValid) {
        // show error
        [self showErrorPasswordNotValidWithMessage:error.localizedDescription];
    }

    if (!isUsernameValid || !isPasswordValid) {
        return;
    }

    [self.activityIndicator startAnimating];
    __weak typeof(self)weakSelf = self;
    [self loginWithServerProfile:self.selectedServerProfile
                        userName:self.usernameTextField.text
                        password:self.passwordTextField.text
                      completion:^(BOOL success) {
                          __strong typeof(self)strongSelf = weakSelf;
                          [strongSelf.activityIndicator stopAnimating];
                          if (success) {
                              [strongSelf dismissViewControllerAnimated:NO completion:nil];
                              if (strongSelf.completion) {
                                  strongSelf.completion();
                              }
                          } else {
                              NSString *errorMessage = @"Wrong credentials";
                              [strongSelf showErrorPasswordNotValidWithMessage:errorMessage];
                          }
                      }];
}

- (IBAction)addNewServerAction:(id)sender
{
    [self hideAddNewServerView];
}

- (IBAction)cancelAddNewServer:(id)sender
{
    [self hideAddNewServerView];
}

- (void)placeholderViewDidTouch:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hideErrors];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [self.organizationTextField becomeFirstResponder];
        return NO;
    } else if (textField == self.organizationTextField) {
        [self.passwordTextField becomeFirstResponder];
        return NO;
    } else if (textField == self.passwordTextField) {
        // TODO: move code from IBAction
        [self loginAction:nil];
        [textField resignFirstResponder];
    } else {
        return YES;
    }
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
- (void)loginWithServerProfile:(JMServerProfile *)serverProfile
                      userName:(NSString *)username
                      password:(NSString *)password
                    completion:(void(^)(BOOL success))loginCompletion
{
    if (!loginCompletion) {
        return;
    }

    JSProfile *jsServerProfile = [[JSProfile alloc] initWithAlias:serverProfile.alias
                                                        serverUrl:serverProfile.serverUrl
                                                     organization:serverProfile.organization
                                                         username:username
                                                         password:password];


    [[JMSessionManager sharedManager] createSessionWithServerProfile:jsServerProfile
                                                          keepLogged:[serverProfile.keepSession boolValue]
                                                          completion:^(BOOL success) {
        loginCompletion(success);
    }];
}

- (BOOL)validateUsername:(NSString *)username error:(NSError **)error
{
    BOOL isValid = YES;
    if (username.length == 0) {
        isValid = NO;
        NSString *message = @"Username is empty";
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"JMAuthenticationDomain"
                                         code:1
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : message
                                     }];
        }
    }
    return isValid;
}

- (BOOL)validatePassword:(NSString *)password error:(NSError **)error
{
    BOOL isValid = YES;
    if (password.length == 0) {
        isValid = NO;
        if (error != NULL) {
            NSString *message = @"Password is empty";
            *error = [NSError errorWithDomain:@"JMAuthenticationDomain"
                                         code:1
                                     userInfo:@{
                                                NSLocalizedDescriptionKey : message
                                                }];
        }
    }
    return isValid;
}


#pragma mark - JMServerViewDelegate
- (void)serverViewDidSelect:(JMServerView *)serverView
{
    switch(serverView.identifier) {
        case 0: {
            // Add new server
            [self showAddNewServerView];
            break;
        }
        case 1: {
            // Demo server

            __weak typeof(self)weakSelf = self;
            [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^(void) {
                __strong typeof(self)strongSelf = weakSelf;
                [strongSelf.restClient cancelAllRequests];
            }];

            [self loginWithServerProfile:[JMServerProfile demoServerProfile]
                                userName:kJMDemoServerUsername
                                password:kJMDemoServerPassword
                              completion:^(BOOL success) {
                                  [JMCancelRequestPopup dismiss];
                                  __strong typeof(self)strongSelf = weakSelf;
                                  if (success) {
                                      [strongSelf dismissViewControllerAnimated:NO completion:nil];
                                      if (strongSelf.completion) {
                                          strongSelf.completion();
                                      }
                                  }
                              }];
            break;
        }
        case 2: {
            self.selectedServerProfile = [self findServerProfileWithAlias:serverView.title];
            self.serverNameLabel.text = self.selectedServerProfile.alias;
            [self showLoginView];
            break;
        }
        default:{}
    }
}

- (JMServerProfile *)findServerProfileWithAlias:(NSString *)alias
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alias == %@", alias];
    fetchRequest.predicate = predicate;
    NSArray *resultArray = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return resultArray.firstObject;
}

- (NSArray <JMServerProfile *>*)allServerProfiles
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    NSArray *resultArray = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return resultArray;
}


@end
