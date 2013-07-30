//
//  JMAskPasswordDialog.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/22/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMAskPasswordDialog.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"

static JMServerProfile * serverProfile;

@implementation JMAskPasswordDialog

// TODO: use custom alert view dialog
+ (UIAlertView *)askPasswordDialogForServerProfile:(JMServerProfile *)profile
{
    NSString *alias = [NSString stringWithFormat:@"%@\n", profile.alias];
    NSMutableString *credentials = [NSMutableString string];
    
    [credentials appendString:profile.username];
    if (profile.organization) {
        [credentials appendFormat:@" | %@", profile.organization];
    }
    
    UIAlertView *askPasswordDialog = [UIAlertView localizedAlertWithTitle:@"servers.askpassword.dialog.title.label"
                                                                  message:@""//[alias stringByAppendingString:credentials]
                                                                 delegate:self
                                                        cancelButtonTitle:@"dialog.button.cancel"
                                                        otherButtonTitles:@"dialog.button.ok", nil];
    serverProfile = profile;
    askPasswordDialog.alertViewStyle = UIAlertViewStyleSecureTextInput;

    UITextField *passwordTextField = [askPasswordDialog textFieldAtIndex:0];
    passwordTextField.placeholder = JMCustomLocalizedString(@"servers.password.label", nil);
    
    return askPasswordDialog;
}

#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex && serverProfile) {
        serverProfile.password = [alertView textFieldAtIndex:0].text ?: @"";
        [JMUtils sendChangeServerProfileNotificationWithProfile:serverProfile];
        serverProfile = nil;
    }
}

@end
