/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
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
//  ServerSettingsViewController.m
//  Jaspersoft Corporation
//

#import "ServerSettingsViewController.h"
#import <jasperserver-mobile-sdk-ios/JSClient.h>
#import "ServersViewController.h"


@implementation ServerSettingsViewController

@synthesize aliasCell, organizationCell, urlCell, usernameCell, passwordCell, client, previousViewController;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	// Add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(saveAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = addButton;
	keybordIsActive = NO;
}


-(IBAction)saveAction:(id)sender {


	bool isNew = NO;
	
    
    if (aliasTextField.text == nil || [aliasTextField.text isEqualToString:@""])
    {
        UIAlertView *uiView =[[[UIAlertView alloc] initWithTitle:@"" message: NSLocalizedString(@"servers.name.errmsg", @"") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [uiView show];
        return;
    }
    
    if (urlTextField.text == nil || [urlTextField.text isEqualToString:@""])
    {
        UIAlertView *uiView =[[[UIAlertView alloc] initWithTitle:@""
                                                         message: NSLocalizedString(@"servers.url.errmsg", @"")
                                                        delegate:nil
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil] autorelease];
        [uiView show];
        return;
    }
    
    if (usernameTextField.text == nil || [usernameTextField.text isEqualToString:@""])
    {
        UIAlertView *uiView =[[[UIAlertView alloc] initWithTitle:@"" message: NSLocalizedString(@"servers.username.errmsg", @"") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [uiView show];
        return;
    }
    
    // Create the new server...
	if (client == nil)
	{
		isNew = YES;
		client = [[[JSClient alloc] init] autorelease];
        client.jsServerProfile = [[[JSServerProfile alloc] init] autorelease];
	}
    
    client.jsServerProfile.alias = aliasTextField.text;
	client.jsServerProfile.baseUrl = urlTextField.text;
	client.jsServerProfile.organization = organizationTextField.text;
	client.jsServerProfile.username = usernameTextField.text;
	client.jsServerProfile.password = passwordTextField.text;
	
	[self.navigationController popViewControllerAnimated:YES];
	
	if (previousViewController != nil && [previousViewController isKindOfClass: [ServersViewController class]])
	{
		
		if (!isNew)
		{
			[(ServersViewController *)previousViewController updateServer:client];
		}
		else {
			[(ServersViewController *)previousViewController addServer:client];
		}
	}

}

// Create a textfield for a specific cell...
- (UITextField *)newTextFieldForCell:(UITableViewCell *)cell {
    CGSize labelSize = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:17]];
    labelSize.width = ceil(labelSize.width/5) * 5; // Round to upper 5
    CGRect frame;
    // Frame values have to be hard coded since the cell has not been added yet to the table
    //if (DeviceIsPad()) {
    //    frame = CGRectMake(labelSize.width + 50,
    //                       11,
    //                       440 - labelSize.width,
    //                       28);
    //} else {
	frame = CGRectMake(labelSize.width + 30,
                           11,
                           cell.frame.size.width - labelSize.width - 50,
                           28);
    //}
	
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


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	return (CGFloat)35.f;
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5; // section is 0?
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
		if ([indexPath section] == 0) {   // User details...
			
				if (indexPath.row == 0) {
					self.aliasCell = [tableView dequeueReusableCellWithIdentifier:@"AliasCell"];
					if (self.aliasCell == nil) {
						self.aliasCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AliasCell"] autorelease];
						self.aliasCell.textLabel.text = NSLocalizedString(@"servers.name.label", @"");
						aliasTextField = [self newTextFieldForCell:self.aliasCell];
						aliasTextField.placeholder = NSLocalizedString(@"servers.name.tip", @"");
						aliasTextField.keyboardType = UIKeyboardTypeDefault;
						aliasTextField.returnKeyType = UIReturnKeyNext;
						if(client != nil && client.jsServerProfile != nil && client.jsServerProfile.alias != nil)
							aliasTextField.text = client.jsServerProfile.alias;
						[self.aliasCell addSubview:aliasTextField];
					}
					
					return self.aliasCell;
				}
				else if (indexPath.row == 1) {
					self.urlCell = [tableView dequeueReusableCellWithIdentifier:@"UrlCell"];
					if (self.urlCell == nil) {
						self.urlCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UrlCell"] autorelease];
						self.urlCell.textLabel.text = NSLocalizedString(@"servers.url.label", @"");
						urlTextField = [self newTextFieldForCell:self.urlCell];
						urlTextField.placeholder = NSLocalizedString(@"servers.url.tip", @"");
						urlTextField.keyboardType = UIKeyboardTypeURL;
						urlTextField.returnKeyType = UIReturnKeyNext;
						if(client != nil && client.jsServerProfile != nil && client.jsServerProfile.baseUrl != nil)
							urlTextField.text = client.jsServerProfile.baseUrl;
						[self.urlCell addSubview:urlTextField];
					}
					
					return self.urlCell;
				}
				else if (indexPath.row == 2) {
					self.organizationCell = [tableView dequeueReusableCellWithIdentifier:@"OrganizationCell"];
					if (self.organizationCell == nil) {
						self.organizationCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OrganizationCell"] autorelease];
						self.organizationCell.textLabel.text = NSLocalizedString(@"servers.orgid.label", @"");
						organizationTextField = [self newTextFieldForCell:self.organizationCell];
						organizationTextField.placeholder = NSLocalizedString(@"servers.orgid.tip", @"");
						organizationTextField.keyboardType = UIKeyboardTypeDefault;
						organizationTextField.returnKeyType = UIReturnKeyNext;
						if(client != nil && client.jsServerProfile != nil && client.jsServerProfile.organization != nil)
							organizationTextField.text = client.jsServerProfile.organization;
						[self.organizationCell addSubview:organizationTextField];
					}
					
					return self.organizationCell;
				}
				else if (indexPath.row == 3) {
					self.usernameCell = [tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
					if (self.usernameCell == nil) {
						self.usernameCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UsernameCell"] autorelease];
						self.usernameCell.textLabel.text = NSLocalizedString(@"servers.username.label", @"");
						usernameTextField = [self newTextFieldForCell:self.usernameCell];
						usernameTextField.placeholder = NSLocalizedString(@"servers.username.tip", @"");
						usernameTextField.keyboardType = UIKeyboardTypeDefault;
						usernameTextField.returnKeyType = UIReturnKeyNext;
						if(client != nil && client.jsServerProfile != nil && client.jsServerProfile.username != nil)
							usernameTextField.text = client.jsServerProfile.username;
						[self.usernameCell addSubview:usernameTextField];
					}
					
					return self.usernameCell;
				}
				else if (indexPath.row == 4) {
					self.passwordCell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
					if (self.passwordCell == nil) {
						self.passwordCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordCell"] autorelease];
						self.passwordCell.textLabel.text = NSLocalizedString(@"servers.password.label", @"");
						passwordTextField = [self newTextFieldForCell:self.passwordCell];
						passwordTextField.placeholder = NSLocalizedString(@"servers.password.tip", @"");
						passwordTextField.keyboardType = UIKeyboardTypeDefault;
						passwordTextField.returnKeyType = UIReturnKeyDone;
						passwordTextField.secureTextEntry = YES;
						passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
						passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
						if(client != nil && client.jsServerProfile != nil && client.jsServerProfile.password != nil)
							passwordTextField.text = client.jsServerProfile.password;
						[self.passwordCell addSubview:passwordTextField];
					}
					
					return self.passwordCell;
				}
		}
	
	// We shouldn't reach this point, but return an empty cell just in case
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoCell"] autorelease];
				    
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */




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


- (void)dealloc {
    [super dealloc];
}

@end
