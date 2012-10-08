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
//  RepositoryViewController.m
//  Jaspersoft Corporation
//

#import <jasperserver-mobile-sdk-ios/JSClient.h>
#import "JSUIRepositoryViewController.h"
#import "JSUIResourceViewController.h"
#import "JSUIReportUnitParametersViewController.h"

@implementation JSUIRepositoryViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    // If the resource selected is a folder, navigate in the folder....
	JSResourceDescriptor *rd = [resources  objectAtIndex: [indexPath indexAtPosition:1]];
	
	if (rd != nil)
	{		
			if ([[rd wsType] compare: JS_TYPE_FOLDER] == 0)
			{
				JSUIRepositoryViewController *rvc = [[JSUIRepositoryViewController alloc] initWithNibName:nil bundle:nil];
                [rvc setClient: self.client];
                [rvc setDescriptor:rd];
				[self.navigationController pushViewController: rvc animated: YES];
				[rvc release];
			} else if ([[rd wsType] compare:JS_TYPE_REPORTUNIT] == 0 || [[rd wsType] compare:JS_TYPE_REPORTOPTIONS] == 0) {
				JSUIReportUnitParametersViewController *rvc = [[JSUIReportUnitParametersViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [rvc setClient: self.client];
				[rvc setDescriptor: rd];
				[self.navigationController pushViewController: rvc animated: YES];
				[rvc release];
			} else {
				JSUIResourceViewController *rvc = [[JSUIResourceViewController alloc] initWithStyle: UITableViewStyleGrouped];
                [rvc setClient: self.client];
				[rvc setDescriptor: rd];
				[self.navigationController pushViewController: rvc animated: YES];
				[rvc release];
			}
	}
}

@end

