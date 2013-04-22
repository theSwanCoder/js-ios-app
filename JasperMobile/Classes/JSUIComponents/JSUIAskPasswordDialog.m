/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSUIAskPasswordDialog.m
//  Jaspersoft Corporation
//

#import "JSUIAskPasswordDialog.h"
#import "JasperMobileAppDelegate.h"

@interface JSUIAskPasswordDialog()

@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) ServerProfile *serverProfile;
@property (nonatomic, retain) id callback;
@property (nonatomic, assign) SEL updateMethod;
@property (nonatomic, retain) UIAlertView *askPasswordAlert;

@end

@implementation JSUIAskPasswordDialog

@synthesize passwordTextField = _passwordTextField;
@synthesize serverProfile = _serverProfile;
@synthesize callback = _callback;
@synthesize updateMethod = _updateMethod;

+ (UIAlertView *)askPasswordDialogForProfile:(ServerProfile *)serverProfile delegate:(id)delegate updateMethod:(SEL)updateMethod {
    static JSUIAskPasswordDialog *tempStorage;
    tempStorage = [[JSUIAskPasswordDialog alloc] initWithProfile:serverProfile callback:delegate updateMethod:updateMethod];
    
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
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordLabel.font = [UIFont boldSystemFontOfSize:14];
    passwordLabel.text = NSLocalizedString(@"servers.password.label", nil);
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
    
    [askPasswordAlert addSubview:passwordLabel];
    [askPasswordAlert addSubview:passwordTextField];
    [tempStorage.passwordTextField becomeFirstResponder];
    
    return askPasswordAlert;
}

- (id)initWithProfile:(ServerProfile *)serverProfile callback:(id)callback updateMethod:(SEL)updateMethod {
    if (self = [super init]) {
        self.serverProfile = serverProfile;
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
    self.serverProfile.password = self.passwordTextField.text ? : @"";
    [[JasperMobileAppDelegate sharedInstance] initProfileForRESTClient:self.serverProfile];
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
