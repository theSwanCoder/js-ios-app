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
 * along with Jaspersoft Mobile. If not, see <http://www.gnu.org/licenses/>.
 */

//
//  RepositoryViewController.m
//  Jaspersoft
//
//  Created by Giulio Toffoli on 4/9/11.
//  Copyright 2011 Jaspersoft Corp.. All rights reserved.
//

#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JSUIRepositoryViewController.h"
#import "JSUIResourceViewController.h"
#import "JSUIReportUnitParametersViewController.h"
#import "JasperMobileAppDelegate.h"
#import "UIAlertView+LocalizedAlert.h"

@implementation JSUIRepositoryViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    // If the resource selected is a folder, navigate in the folder....
	JSResourceDescriptor *rd = [resources  objectAtIndex: [indexPath indexAtPosition:1]];
    JSConstants *constants = [JSConstants sharedInstance];
	
	if (rd != nil) {		
        if ([rd.wsType compare:constants.WS_TYPE_FOLDER] == 0) {
            JSUIRepositoryViewController *rvc = [[JSUIRepositoryViewController alloc] initWithNibName:nil bundle:nil];
            [rvc setResourceClient: self.resourceClient];
            [rvc setDescriptor:rd];
            [self.navigationController pushViewController: rvc animated: YES];
        } else if ([rd.wsType compare:constants.WS_TYPE_REPORT_UNIT] == 0 ||
                   [rd.wsType compare:constants.WS_TYPE_REPORT_OPTIONS] == 0) {
            JSUIReportUnitParametersViewController *rvc = [[JSUIReportUnitParametersViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [rvc setReportClient: [JasperMobileAppDelegate sharedInstance].reportClient];
            [rvc setDescriptor: rd];
            [self.navigationController pushViewController: rvc animated: YES];
        } else {
            JSUIResourceViewController *rvc = [[JSUIResourceViewController alloc] initWithStyle: UITableViewStyleGrouped];
            [rvc setResourceClient:self.resourceClient];
            [rvc setDescriptor: rd];
            [self.navigationController pushViewController: rvc animated: YES];
        }
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end

