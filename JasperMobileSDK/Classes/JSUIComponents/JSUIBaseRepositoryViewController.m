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
//  JSUIRepositoryViewController.m
//  Jaspersoft
//
//  Created by Giulio Toffoli on 7/22/11.
//  Copyright 2011 Jaspersoft. All rights reserved.
//

#import "JSUIResourceViewController.h"
#import "JSUIBaseRepositoryViewController.h"
#import "JSUILoadingView.h"
#import "JasperMobileAppDelegate.h"
#import "UIAlertView+LocalizedAlert.h"

@implementation JSUIBaseRepositoryViewController

@synthesize descriptor;
@synthesize resourceClient;
@synthesize resources;

#pragma mark -
#pragma mark View lifecycle

- (id)init {
    self = [super init];
    resources = nil;    
    descriptor = nil;
    resourceClient = nil;
    
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];	
}

- (void)requestFinished:(JSOperationResult *)result {  
	if (result.error != nil) {     
        NSString *errorMsg = nil;
        NSString *errorTitle = @"error.readingresponse.dialog.msg";
 
        if (result.error) {
            // Authorization problem
            if ((result.error.code == -1012 && result.statusCode == 0) || result.statusCode == 401) {
                errorMsg = @"error.authenication.dialog.msg";
                errorTitle = @"error.authenication.dialog.title";
            } else {
                errorMsg = [[result error] localizedDescription];
            }
        }
        
        [[UIAlertView localizedAlert:errorTitle 
                             message:errorMsg 
                            delegate:nil 
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];        
    } else {
		resources = [[NSMutableArray alloc] initWithCapacity:0];
        for (JSResourceDescriptor *resourceDescriptor in result.objects) {
            [self.resources addObject:resourceDescriptor];
        }
	}
	
	// Update the table
	[[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
	[JSUILoadingView hideLoadingView];
}

- (void)viewWillAppear:(BOOL)animated {   
    [self.navigationController setToolbarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[JasperMobileAppDelegate sharedInstance].tabBarController setSelectedIndex:3];
}

- (void)clear {
    self.navigationItem.title = nil;
    
	if (resources != nil) {
        resources = nil;
        [[self tableView] reloadData];
    }
	descriptor = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![JSRESTBase isNetworkReachable]) {
        [[UIAlertView localizedAlert:@"error.noconnection.dialog.title" 
                             message:@"error.noconnection.dialog.msg" 
                            delegate:self 
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];
        return;
    } else {
        [self performSelector:@selector(updateTableContent) withObject:nil afterDelay:0.0];
	}
}

- (void)refreshContent {
    if (resources != nil) {
        resources = nil;
    }
    
    [self updateTableContent];
}

- (void)updateTableContent {
    if (self.resourceClient == nil) {
        JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
        if (app.servers.count) {
            [app setProfile:[app.servers objectAtIndex:0]];
            [self updateTableContent];
            return;
        } else {
            [[UIAlertView localizedAlert:@"noservers.dialog.title" 
                                 message:@"noservers.dialog.msg" 
                                delegate:self 
                       cancelButtonTitle:@"noservers.dialog.button.label"
                       otherButtonTitles:nil] show];
            return;
        }
    }
    
    if ([JSRESTBase isNetworkReachable] && self.resources == nil) {
		NSString *uri = @"/";
		if (self.descriptor != nil) {
			uri =  [self.descriptor uriString];
			self.navigationItem.title = [NSString stringWithFormat:@"%@", [descriptor label]];
		} else {
			self.navigationItem.title = [NSString stringWithFormat:@"%@", [self.resourceClient.serverProfile alias] ];
		}
		// load this view
        [JSUILoadingView showCancelableLoadingInView:self.view restClient:self.resourceClient delegate:self cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.resourceClient resources:uri delegate:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return (CGFloat)0.f;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	if (self.resources != nil) {
		return [self.resources count];
	}
	
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSResourceDescriptor *rd = (JSResourceDescriptor *)[resources objectAtIndex: [indexPath indexAtPosition:1]];
    
    UITableViewCell *cell;
    NSString *imageNameAndCellIdentifier = nil;
    
    JSConstants *constants = [JSConstants sharedInstance];
    
    if ([rd.wsType isEqualToString: constants.WS_TYPE_FOLDER]) {
        imageNameAndCellIdentifier = @"ic_type_folder.png";
    } else if ([rd.wsType isEqualToString: constants.WS_TYPE_FOLDER]) {
        imageNameAndCellIdentifier = @"ic_type_image.png";
    } else if ([rd.wsType isEqualToString: constants.WS_TYPE_REPORT_UNIT]) {
        imageNameAndCellIdentifier = @"ic_type_report.png";
    } else if ([rd.wsType isEqualToString: constants.WS_TYPE_DASHBOARD]) {
        imageNameAndCellIdentifier = @"ic_type_dashboard.png";
    } else if([rd.wsType isEqualToString: constants.WS_TYPE_CSS] || 
              [rd.wsType isEqualToString: constants.WS_TYPE_XML]) {
        imageNameAndCellIdentifier = @"ic_type_text.png";
    } else {
        imageNameAndCellIdentifier = @"ic_type_unknown.png";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:imageNameAndCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:imageNameAndCellIdentifier];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = [UIImage imageNamed:imageNameAndCellIdentifier];
        cell.textLabel.textColor = [UIColor colorWithRed:46.0/255.0 green:109.0/255.0 blue:159.0/255.0  alpha:1];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
    }
    
	// Configure the cell.    
    cell.textLabel.text = rd.label;
	cell.detailTextLabel.text = rd.uriString;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.userInteractionEnabled = true;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    self.descriptor = [resources objectAtIndex: [indexPath indexAtPosition:1]];
    if (self.descriptor)
	{
		JSUIResourceViewController *rvc = [[JSUIResourceViewController alloc] initWithStyle:UITableViewStyleGrouped];
        rvc.resourceClient = self.resourceClient;
        rvc.descriptor = self.descriptor;
		[self.navigationController pushViewController: rvc animated: YES];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

@end

