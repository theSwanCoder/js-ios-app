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
//  ServerSettingsViewController.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>
#import <jasperserver-mobile-sdk-ios/JSClient.h>

@interface ServerSettingsViewController : UITableViewController <UITextFieldDelegate, UITableViewDelegate> {

	bool keybordIsActive;
	UITextField *aliasTextField, *organizationTextField, *urlTextField, *usernameTextField, *passwordTextField;

}

@property (nonatomic, retain) UITableViewCell *aliasCell, *urlCell, *organizationCell, *usernameCell, *passwordCell;
@property (nonatomic, retain) JSClient *client;
@property (nonatomic, retain) UIViewController *previousViewController;


- (bool)textFieldShouldReturn:(UITextField *)textField;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
