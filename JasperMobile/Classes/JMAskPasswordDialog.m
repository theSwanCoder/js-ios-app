/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMAskPasswordDialog.m
//  Jaspersoft Corporation
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
