//
//  JSUIAskPasswordDialog.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 10.10.12.
//
//

#import "JSUIAskPasswordDialog.h"
#import "JasperMobileAppDelegate.h"

@interface JSUIAskPasswordDialog()

@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) JSProfile *profile;
@property (nonatomic, retain) id callback;
@property (nonatomic, assign) SEL updateMethod;
@property (nonatomic, retain) UIAlertView *askPasswordAlert;

@end

@implementation JSUIAskPasswordDialog

@synthesize passwordTextField = _passwordTextField;
@synthesize profile = _profile;
@synthesize callback = _callback;
@synthesize updateMethod = _updateMethod;

+ (UIAlertView *)askPasswordDialogForProfile:(JSProfile *)profile delegate:(id)delegate updateMethod:(SEL)updateMethod {
    static JSUIAskPasswordDialog *tempStorage;
    tempStorage = [[JSUIAskPasswordDialog alloc] initWithProfile:profile callback:delegate updateMethod:updateMethod];
    
    UIAlertView *askPasswordAlert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"servers.askpassword.dialog.title.label", nil)
                 message:@"\n\n"
                 delegate:tempStorage
                 cancelButtonTitle:nil
                 otherButtonTitles:NSLocalizedString(@"dialog.button.ok", nil), NSLocalizedString(@"dialog.button.cancel", nil), nil];
    
    NSInteger xPos = 12;
    NSInteger yPos = 40;
    NSInteger yPosInc = 17;
    NSInteger generalWidth = 260;
    
//    UILabel *profLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    profLabel.font = [UIFont boldSystemFontOfSize:14];
//    profLabel.backgroundColor = [UIColor clearColor];
//    profLabel.textColor = [UIColor whiteColor];
//    profLabel.text = [NSString stringWithFormat:@"%@: %@",
//                           NSLocalizedString(@"servers.name.label", @""), profile.alias];
//    CGSize generalSize = [profLabel.text sizeWithFont:profLabel.font];
//    CGRect generalRect = CGRectMake(xPos, yPos, generalWidth, generalSize.height);
//    profLabel.frame = generalRect;
//    
//    generalRect.origin.y += yPosInc;
//    UILabel *orgLabel = [[UILabel alloc] initWithFrame:generalRect];
//    orgLabel.font = [UIFont boldSystemFontOfSize:14];
//    orgLabel.backgroundColor = [UIColor clearColor];
//    orgLabel.textColor = [UIColor whiteColor];
//    orgLabel.text = [NSString stringWithFormat:@"%@: %@",
//                          NSLocalizedString(@"servers.orgid.label", @""), profile.organization];
//
//    generalRect.origin.y += yPosInc;
//    UILabel *userLabel = [[UILabel alloc] initWithFrame:generalRect];
//    userLabel.font = [UIFont boldSystemFontOfSize:14];
//    userLabel.backgroundColor = [UIColor clearColor];
//    userLabel.textColor = [UIColor whiteColor];
//    userLabel.text = [NSString stringWithFormat:@"%@: %@",
//                           NSLocalizedString(@"servers.username.label", @""), profile.username];
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordLabel.font = [UIFont boldSystemFontOfSize:14];
    passwordLabel.text = NSLocalizedString(@"servers.password.label", @"");
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.backgroundColor = [UIColor clearColor];
    CGSize generalSize = [passwordLabel.text sizeWithFont:passwordLabel.font];
    CGRect generalRect = CGRectMake(xPos, yPos, generalWidth, generalSize.height);
    
    generalRect.size.width = [passwordLabel.text sizeWithFont:passwordLabel.font].width;
    passwordLabel.frame = generalRect;
    
    generalRect.origin.y += yPosInc + 2;
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:
                                      CGRectMake(xPos, generalRect.origin.y, 260, 35)];
    passwordTextField.adjustsFontSizeToFitWidth = YES;
    passwordTextField.textColor = [UIColor blackColor];
    passwordTextField.placeholder = NSLocalizedString(@"servers.password.tip", nil);
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField.textAlignment = UITextAlignmentLeft;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.enabled = YES;
    passwordTextField.secureTextEntry = YES;
    tempStorage.passwordTextField = passwordTextField;
    tempStorage.askPasswordAlert = askPasswordAlert;
    
//    [askPasswordAlert addSubview:profLabel];
//    [askPasswordAlert addSubview:orgLabel];
//    [askPasswordAlert addSubview:userLabel];
    [askPasswordAlert addSubview:passwordLabel];
    [askPasswordAlert addSubview:passwordTextField];
    [tempStorage.passwordTextField becomeFirstResponder];
    
    return askPasswordAlert;
}

- (id)initWithProfile:(JSProfile *)profile callback:(id)callback updateMethod:(SEL)updateMethod {
    if (self = [super init]) {
        self.profile = profile;
        self.callback = callback;
        self.updateMethod = updateMethod;
    }
    
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.askPasswordAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self updateProfile];
    return YES;
}

- (void)updateProfile {
    self.profile.password = self.passwordTextField.text ? : @"";
    [[JasperMobileAppDelegate sharedInstance] setProfile:self.profile];
    if (self.updateMethod && [self.callback respondsToSelector:self.updateMethod]) {
        [self.callback performSelector:self.updateMethod];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self updateProfile];
    }
}



@end
