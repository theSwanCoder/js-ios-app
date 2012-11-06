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
//  ServersViewController.m
//  Jaspersoft Corporation
//

#import "ServersViewController.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JasperMobileAppDelegate.h"
#import "SSKeychain.h"
#import "JSProfile+Helpers.h"
#import "JSUIAskPasswordDialog.h"

@implementation ServersViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
	[[self tableView] setAllowsSelectionDuringEditing: YES];
	self.title = @"Servers";
	
	editDoneButton = [[UIBarButtonItem alloc] initWithTitle: @"Edit"
					   style: UIBarButtonItemStylePlain
					   target:self action:@selector(editClicked:)];
	
	editMode = false;
	self.navigationItem.rightBarButtonItem = editDoneButton;
	
	if ([[[JasperMobileAppDelegate sharedInstance] servers] count] == 0)
	{
		[self editProfile:nil];
	}
	
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle: @"Info"
                                      style: UIBarButtonItemStylePlain
                                      target:self action:@selector(infoClicked:)];
    
    
	self.navigationItem.rightBarButtonItem = editDoneButton;
    self.navigationItem.leftBarButtonItem = infoButton;
    
	[super viewDidLoad];	
}

-(void)editClicked:(id)sender {
	
	editDoneButton.title = @"Done";
	editDoneButton.action = @selector(doneClicked:);
	editMode = true;
	
	
	[[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
	
	[[self tableView] setEditing:true animated:YES];
    
    
    if ([[[JasperMobileAppDelegate sharedInstance] servers] count] == 0)
    {
        // Run the view to configure something...
        ServerSettingsViewController *vc  = [[ServerSettingsViewController alloc] initWithNibName: @"ServerSettingsViewController" bundle:nil];
        vc.previousViewController = self;
        [self.navigationController pushViewController: vc animated: YES];
    }
    
}

- (void)infoClicked:(id)sender {
    NSString *mssg = NSLocalizedString(@"servers.info", nil);
    mssg = [NSString stringWithFormat:mssg, [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    [[[UIAlertView alloc] initWithTitle:@"" message:mssg delegate:nil cancelButtonTitle:NSLocalizedString(@"dialog.button.ok", nil) otherButtonTitles:nil] show];
}


-(void)doneClicked:(id)sender {
	
	editDoneButton.title = @"Edit";
	editDoneButton.action = @selector(editClicked:);
	editMode = false;
	
	[[self tableView] setEditing:false animated:YES];
	
	[[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];	
}


 

 - (void)viewDidAppear:(BOOL)animated {
	 [super viewDidAppear:animated];	 
}


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
    
	return @"JasperReports Server profiles";
		
}


// Customize the number of rows in the table view.
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {    
    if (!editMode) {
        NSInteger serversCount = [[[JasperMobileAppDelegate sharedInstance] servers] count];
        
        if (serversCount == 1) {
            JSProfile *profile = [[JasperMobileAppDelegate sharedInstance].servers objectAtIndex:0];
            if ([profile.alias isEqualToString:@"Jaspersoft Mobile Demo"]) {
                return @"\n\nYou can add and configure your own server by tapping Edit, or you can select the demo server provided by Jaspersoft to quickly try out how the app works.";
            }
        } else if (serversCount == 0) {
            return @"Please add and configure a JasperReports Server account by tapping Edit.";
        }
    }
    
    return NULL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (editMode)
		return [[[JasperMobileAppDelegate sharedInstance] servers] count] + 1; // section is 0?
	
	return [[[JasperMobileAppDelegate sharedInstance] servers] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSString *CellAddAccount = @"AddAccount";
    
	if ([indexPath indexAtPosition: 1] >= [[[JasperMobileAppDelegate sharedInstance] servers] count])
	{
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellAddAccount];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddAccount];
		}
		cell.textLabel.text = @"New server account...";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	
	if (editMode)
	{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			}
			
			// Configure the cell.
			JSProfile *profile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
			cell.textLabel.text = profile.alias;
			cell.detailTextLabel.text = profile.serverUrl;
			cell.accessoryType = UITableViewCellAccessoryNone;
			return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		}
		
		// Configure the cell.
		JSProfile *profile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
		cell.textLabel.text = profile.alias;
		cell.detailTextLabel.text = profile.serverUrl;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}

    
}



 // Override to support conditional editing of the table view.
 - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	 if (editMode == YES && [indexPath indexAtPosition: 1] < [[[JasperMobileAppDelegate sharedInstance] servers] count])
	 {
		return UITableViewCellEditingStyleDelete;
	 }
	 return UITableViewCellEditingStyleNone;
 }
 



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
	 if (editMode)
	 {
		 if (editingStyle == UITableViewCellEditingStyleDelete) {
			 // Delete the row from the data source.
			 JSProfile *profile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
			 NSInteger index = [[[JasperMobileAppDelegate sharedInstance] servers] indexOfObject:profile];
			 if (index >= 0) {
                 [[JasperMobileAppDelegate sharedInstance].favorites clearFavoritesAndSynchronizeWithUserDefaults];
				 [[[JasperMobileAppDelegate sharedInstance] servers] removeObjectAtIndex:index];
                 [SSKeychain deletePasswordForService:[JasperMobileAppDelegate keychainServiceName] account:[profile profileID]];
				 [[JasperMobileAppDelegate sharedInstance] saveServers];
			 }
			 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
             
             // If the profile is currently in use... remove it...
             [[JasperMobileAppDelegate sharedInstance] setProfile: nil];    
		 }
	 }
 }

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	JSProfile *profile = nil;
	if ([indexPath indexAtPosition: 1] < [[[JasperMobileAppDelegate sharedInstance] servers] count])
	{
		// Get the info of this client....
		profile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
	}
	
	if (!editMode)
	{
		if (profile == nil) return;
        JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
        
        if (profile.alwaysAskPassword.boolValue) {
            profile.password = nil;
            [app disableTabBar];
            [app setProfile:profile];
            [[JSUIAskPasswordDialog askPasswordDialogForProfile:profile delegate:self updateMethod:@selector(updateProfilePassword)] show];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
            return;
        } else {
            [app enableTabBar];
        }
        
        [app setProfile:profile];
		[[JasperMobileAppDelegate sharedInstance] configureServersDone:self];
		return;
	}
	
	[self editProfile: profile];	
}

- (void)updateProfilePassword {
    JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
    [app enableTabBar];
    [app.tabBarController setSelectedIndex:0];
}
		 
- (void)editProfile:(JSProfile *)profile {
	ServerSettingsViewController *vc  = [[ServerSettingsViewController alloc] initWithNibName: @"ServerSettingsViewController" bundle:nil];
	vc.profile = profile;
	vc.previousViewController = self;
	[self.navigationController pushViewController: vc animated: YES];
}


-(void)addServer:(JSProfile *)profile
{
	[[[JasperMobileAppDelegate sharedInstance] servers] addObject:profile];
	[[JasperMobileAppDelegate sharedInstance] saveServers];
	
    [[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
}

-(void)updateServer:(JSProfile *)profile
{
	[[JasperMobileAppDelegate sharedInstance] saveServers];
	[[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
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
