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
//  JSUISearchViewController.m
//  Jaspersoft Corporation
//

#import "JSUISearchViewController.h"
#import "JSUIRepositoryViewController.h"
#import "JSUIReportUnitParametersViewController.h"
#import "JSUIResourceViewController.h"
#import "JSUILoadingView.h"
#import "JasperMobileAppDelegate.h"
#import "JSUIDashboardViewController.h"
#import "UIAlertView+LocalizedAlert.h"

@implementation JSUISearchViewController

- (id)init {
    self = [super init];
    self.resources = nil;    
    self.descriptor = nil;
    self.resourceClient = nil;
    
    return self;
}

- (void)updateTableContent {
    // does nothing...
}

// Called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)sBar {
    NSString *searchText = [sBar text];
    if ([searchText length] > 0) {
        [sBar resignFirstResponder];
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setObject:searchText forKey: @"q"];
        [args setObject:@"1" forKey:@"recursive"];
        
        [self.resourceClient resources:@"" query:searchText types:nil recursive:YES limit:-1 delegate:self];        
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sBar {
    [self.resourceClient cancelRequestsWithDelegate:self];
    [sBar resignFirstResponder];
}  

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];    
    [super loadView];
    
    self.view = [[UIView alloc] init];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)]; 
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:searchBar];
    
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, 320, 323)];
    tableView.delegate = self;
    tableView.dataSource = self;   
    [self.view addSubview:tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)requestFinished:(JSOperationResult *)result {
    if (result.error) {
        [[self class] displayErrorMessage:result];
    } else {
		resources = [[NSMutableArray alloc] initWithCapacity:0];
		
		// Show resources
		for (NSUInteger i = 0; i < result.objects.count; ++i) {
			JSResourceDescriptor *rd = [result.objects objectAtIndex:i];
			[resources addObject:rd];
		}
	}
	
	// Update the table
    [tableView reloadData];
	[JSUILoadingView hideLoadingView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
	if (resources != nil)
	{
		return [resources count];
	}
	
    return 0; // section is 0?
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JSConstants *constants = [JSConstants sharedInstance];
    
    // If the resource selected is a folder, navigate in the folder....
	JSResourceDescriptor *rd = [resources  objectAtIndex: [indexPath indexAtPosition:1]];
	
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
        } else if ([rd.wsType compare:constants.WS_TYPE_DASHBOARD] == 0) {
            JSUIDashboardViewController *rvc = [[JSUIDashboardViewController alloc] initWithNibName:nil bundle:nil];
            [rvc setResourceClient: self.resourceClient];
            [rvc setDescriptor: rd];
            [self presentModalViewController:rvc animated:YES];
        } else {
            JSUIResourceViewController *rvc = [[JSUIResourceViewController alloc] initWithStyle: UITableViewStyleGrouped];
            [rvc setResourceClient:self.resourceClient];
            [rvc setDescriptor: rd];
            [self.navigationController pushViewController: rvc animated: YES];
        }
	}
}

- (void)viewDidAppear:(BOOL)animated {
    if (![JSRESTBase isNetworkReachable]) {
        [[UIAlertView localizedAlert:@"error.noconnection.dialog.title" 
                             message:@"error.noconnection.dialog.msg" 
                            delegate:self 
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];
        return;
    } else {
        [super viewDidAppear:animated];
    }
}

@end
