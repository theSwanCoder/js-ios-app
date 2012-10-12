/*
 * Jaspersoft Mobile SDK
 * Copyright (C) 2001 - 2011 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is part of Jaspersoft Mobile SDK.
 *
 * Jaspersoft Mobile SDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Jaspersoft Mobile SDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Jaspersoft Mobile SDK. If not, see <http://www.gnu.org/licenses/>.
 */

//
//  ServerSettingsViewController.m
//  Jaspersoft
//
//  Created by Giulio Toffoli on 4/12/11.
//  Copyright 2011 Jaspersoft Corp.. All rights reserved.
//

#import "ServerSettingsViewController.h"
#import "ServersViewController.h"
#import "JasperMobileAppDelegate.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JSProfile+Helpers.h"

@implementation ServerSettingsViewController

@synthesize aliasCell;
@synthesize organizationCell;
@synthesize urlCell;
@synthesize usernameCell;
@synthesize passwordCell;
@synthesize profile;
@synthesize previousViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(saveAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	keybordIsActive = NO;
}


- (IBAction)saveAction:(id)sender {
	bool isNew = NO;
    
    if (aliasTextField.text == nil || [aliasTextField.text isEqualToString:@""]) {
        [[UIAlertView localizedAlert:@"" message:@"servers.name.errmsg.empty" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];        
        return;
    }
    
    for (JSProfile *serverProfile in [JasperMobileAppDelegate sharedInstance].servers) {
        if (![serverProfile isEqual:profile] && [serverProfile.alias isEqualToString:aliasTextField.text]) {
            [[UIAlertView localizedAlert:@"" message:@"servers.name.errmsg.exists" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];        
            return;
        }
    }
    
    if (urlTextField.text == nil || [urlTextField.text isEqualToString:@""])
    {
        [[UIAlertView localizedAlert:@"" message:@"servers.url.errmsg" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
        return;
    }
    
    if (usernameTextField.text == nil || [usernameTextField.text isEqualToString:@""])
    {
        [[UIAlertView localizedAlert:@"" message:@"servers.username.errmsg.empty" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
        return;
    }
    
    for (JSProfile *serverProfile in [JasperMobileAppDelegate sharedInstance].servers) {
        if (profile && [serverProfile isEqual:profile]) {
            continue;
        } else if ([serverProfile isEqualToProfileByServerURL:urlTextField.text username:usernameTextField.text 
                                          organization:organizationTextField.text]) {
            [[UIAlertView localizedAlert:@"" message:@"servers.profile.exists" delegate:nil 
                       cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
            return;
        }
    }
    
    // Create the new server
	if (profile == nil) {
		isNew = YES;
        profile = [[JSProfile alloc] init];
	}

    profile.alias = aliasTextField.text;
    profile.serverUrl = urlTextField.text;
    profile.organization = organizationTextField.text;
    profile.username = usernameTextField.text;
    profile.password = passwordTextField.text;
    profile.tempPassword = profile.password;
    profile.alwaysAskPassword = [NSNumber numberWithBool:askPasswordSwitch.on];
	
	[self.navigationController popViewControllerAnimated:YES];
	
	if (previousViewController != nil && [previousViewController isKindOfClass: [ServersViewController class]]) {
		
		if (!isNew) {
			[(ServersViewController *)previousViewController updateServer:profile];
		} else {
			[(ServersViewController *)previousViewController addServer:profile];
		}
	}
}

// Create a textfield for a specific cell...
- (UITextField *)newTextFieldForCell:(UITableViewCell *)cell {
    CGSize labelSize = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:17]];
    labelSize.width = ceil(labelSize.width/5) * 5;
    CGRect frame;

	frame = CGRectMake(labelSize.width + 30, 11, cell.frame.size.width - labelSize.width - 50, 28);	
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor clearColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.textAlignment = UITextAlignmentLeft;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.enabled = YES;
    textField.returnKeyType = UIReturnKeyDone;
	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return textField;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    
	return @"Server Profile Details";	
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6; // section is 0?
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {   // User details...
        
		if (indexPath.row == 0) {
            self.aliasCell = [tableView dequeueReusableCellWithIdentifier:@"AliasCell"];
            
            if (self.aliasCell == nil) {
				self.aliasCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AliasCell"];
				self.aliasCell.textLabel.text = NSLocalizedString(@"Name", @"");
				aliasTextField = [self newTextFieldForCell:self.aliasCell];
				aliasTextField.placeholder = NSLocalizedString(@"My server", @"");
				aliasTextField.keyboardType = UIKeyboardTypeDefault;
				aliasTextField.returnKeyType = UIReturnKeyNext;
				if(profile != nil && profile.alias != nil)
					aliasTextField.text = profile.alias;
				[self.aliasCell addSubview:aliasTextField];
			}
			
			return self.aliasCell;
               
		} else if (indexPath.row == 1) {
			self.urlCell = [tableView dequeueReusableCellWithIdentifier:@"UrlCell"];
			if (self.urlCell == nil) {
				self.urlCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UrlCell"];
				self.urlCell.textLabel.text = NSLocalizedString(@"URL", @"");
				urlTextField = [self newTextFieldForCell:self.urlCell];
				urlTextField.placeholder = NSLocalizedString(@"http://example.com/jasperserver", @"");
				urlTextField.keyboardType = UIKeyboardTypeURL;
				urlTextField.returnKeyType = UIReturnKeyNext;
				if(profile != nil && profile.serverUrl != nil)
					urlTextField.text = profile.serverUrl;
				[self.urlCell addSubview:urlTextField];
			}
			return self.urlCell;
               
		} else if (indexPath.row == 2) {
			self.organizationCell = [tableView dequeueReusableCellWithIdentifier:@"OrganizationCell"];
			if (self.organizationCell == nil) {
				self.organizationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OrganizationCell"];
				self.organizationCell.textLabel.text = NSLocalizedString(@"Organization", @"");
				organizationTextField = [self newTextFieldForCell:self.organizationCell];
				organizationTextField.placeholder = NSLocalizedString(@"organization id", @"");
				organizationTextField.keyboardType = UIKeyboardTypeDefault;
				organizationTextField.returnKeyType = UIReturnKeyNext;
				if(profile != nil && profile.organization != nil)
					organizationTextField.text = profile.organization;
				[self.organizationCell addSubview:organizationTextField];
			}
			return self.organizationCell;
               
		} else if (indexPath.row == 3) {
			self.usernameCell = [tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
			if (self.usernameCell == nil) {
				self.usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UsernameCell"];
				self.usernameCell.textLabel.text = NSLocalizedString(@"Username", @"");
				usernameTextField = [self newTextFieldForCell:self.usernameCell];
				usernameTextField.placeholder = @"my username"; // NOI18N
				usernameTextField.keyboardType = UIKeyboardTypeDefault;
				usernameTextField.returnKeyType = UIReturnKeyNext;
				if(profile != nil && profile.username != nil)
					usernameTextField.text = profile.username;
				[self.usernameCell addSubview:usernameTextField];
			}
			return self.usernameCell;
               
		} else if (indexPath.row == 4) {
			self.passwordCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
			if (self.passwordCell == nil) {
				self.passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordCell"];
				self.passwordCell.textLabel.text = NSLocalizedString(@"Password", @"");
				passwordTextField = [self newTextFieldForCell:self.passwordCell];
				passwordTextField.placeholder = @"my password"; // NOI18N
				passwordTextField.keyboardType = UIKeyboardTypeDefault;
				passwordTextField.returnKeyType = UIReturnKeyDone;
				passwordTextField.secureTextEntry = YES;
				passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
				passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                
                if (!profile.alwaysAskPassword.boolValue) {
                    passwordTextField.text = profile.password ?: profile.tempPassword;
                } else {
                    passwordTextField.textColor = [UIColor lightGrayColor];
                    self.passwordCell.textLabel.textColor = [UIColor lightGrayColor];
                }
                
				[self.passwordCell addSubview:passwordTextField];
			}
			return self.passwordCell;
               
		} else if (indexPath.row == 5) {
            UITableViewCell *askPasswordCell = [tableView dequeueReusableCellWithIdentifier:@"AskPasswordCell"];
			if (askPasswordCell == nil) {
                askPasswordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AskPasswordCell"];
                askPasswordCell.textLabel.text = NSLocalizedString(@"servers.askpassword.label", @"");
                askPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
                askPasswordCell.textLabel.font = [UIFont systemFontOfSize:15];
                
                CGSize labelSize = [askPasswordCell.textLabel.text sizeWithFont:askPasswordCell.textLabel.font];
                labelSize.width = ceil(labelSize.width / 5) * 5;
                CGRect frame = CGRectMake(labelSize.width + 30, 8, askPasswordCell.frame.size.width - labelSize.width - 50, 28);
                askPasswordSwitch = [[UISwitch alloc] initWithFrame:frame];
                askPasswordSwitch.on = profile.alwaysAskPassword.boolValue;
                [askPasswordSwitch addTarget:self action:@selector(askPasswordSwitchToggled:) forControlEvents:UIControlEventTouchUpInside];
                
                [askPasswordCell addSubview:askPasswordSwitch];
            }
            
            return askPasswordCell;
        }
	}
	// We shouldn't reach this point, but return an empty cell just in case
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoCell"];
				    
}

- (void)askPasswordSwitchToggled:(id)sender {
    UITableViewCell *askPasswordCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    if ([sender isOn]) {
        passwordTextField.enabled = NO;
        passwordTextField.textColor = [UIColor lightGrayColor];
        [askPasswordCell textLabel].textColor = [UIColor lightGrayColor];
    } else {
        passwordTextField.enabled = YES;
        passwordTextField.textColor = [UIColor blackColor];
        [askPasswordCell textLabel].textColor = [UIColor blackColor];
    }
}

- (bool)textFieldShouldReturn:(UITextField *)textField
{
	if (textField.returnKeyType == UIReturnKeyNext) {
        UITableViewCell *cell = (UITableViewCell *)[textField superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
        if (nextCell) {
            for (UIView *subview in [nextCell subviews]) {
                if ([subview isKindOfClass:[UITextField class]]) {
                    [subview becomeFirstResponder];
                    break;
                }
            }
        }
    }
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end
