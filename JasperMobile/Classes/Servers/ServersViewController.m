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
#import "JasperMobileAppDelegate.h"
#import "JSUIAskPasswordDialog.h"
#import "JSLocalization.h"

@implementation ServersViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[[self tableView] setAllowsSelectionDuringEditing: YES];
	self.title = JSCustomLocalizedString(@"view.servers", nil);
	
	editDoneButton = [[UIBarButtonItem alloc] initWithTitle:JSCustomLocalizedString(@"dialog.button.edit", nil)
					   style: UIBarButtonItemStylePlain
					   target:self action:@selector(editClicked:)];
	
	editMode = false;
	self.navigationItem.rightBarButtonItem = editDoneButton;
	
	if ([[[JasperMobileAppDelegate sharedInstance] servers] count] == 0) {
		[self editProfile:nil];
	}
	
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
                                   initWithTitle:JSCustomLocalizedString(@"dialog.button.info", nil)
                                   style: UIBarButtonItemStylePlain
                                   target:self action:@selector(infoClicked:)];
    
	self.navigationItem.rightBarButtonItem = editDoneButton;
    self.navigationItem.leftBarButtonItem = infoButton;
    
	[super viewDidLoad];	
}

- (void)editClicked:(id)sender {
	editMode = YES;
    
    if ([[[JasperMobileAppDelegate sharedInstance] servers] count] == 0) {
        // Run the view to configure something...
        ServerSettingsViewController *vc  = [[ServerSettingsViewController alloc] initWithNibName: @"ServerSettingsViewController" bundle:nil];
        vc.previousViewController = self;
        [self.navigationController pushViewController:vc animated: YES];
    } else {
        editDoneButton.title = JSCustomLocalizedString(@"dialog.button.done", nil);
        editDoneButton.action = @selector(doneClicked:);
        [[self tableView] beginUpdates];
        [[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [[self tableView] endUpdates];
        [[self tableView] setEditing:true animated:YES];
    }
}

- (void)infoClicked:(id)sender {
    NSString *mssg = JSCustomLocalizedString(@"servers.info", nil);
    mssg = [NSString stringWithFormat:mssg, [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    [[[UIAlertView alloc] initWithTitle:nil message:mssg delegate:nil cancelButtonTitle:JSCustomLocalizedString(@"dialog.button.ok", nil) otherButtonTitles:nil] show];
}

- (void)doneClicked:(id)sender {
	editDoneButton.title = JSCustomLocalizedString(@"dialog.button.edit", nil);
	editDoneButton.action = @selector(editClicked:);
	editMode = NO;
	
	[[self tableView] setEditing:false animated:YES];
	[[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
}

- (void)viewDidAppear:(BOOL)animated {
	 [super viewDidAppear:animated];	 
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return JSCustomLocalizedString(@"servers.profile.title", nil);
}

// Customize the number of rows in the table view.
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {    
    if (!editMode) {
        NSInteger serversCount = [[[JasperMobileAppDelegate sharedInstance] servers] count];
        
        if (serversCount == 1) {
            ServerProfile *serverProfile = [[JasperMobileAppDelegate sharedInstance].servers objectAtIndex:0];
            if ([serverProfile.alias isEqualToString:@"Jaspersoft Mobile Demo"]) {
                return JSCustomLocalizedString(@"servers.profile.configure.tips", nil);
            }
        } else if (serversCount == 0) {
            return JSCustomLocalizedString(@"servers.profile.configure.help", nil);
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
    
	if ([indexPath indexAtPosition: 1] >= [[[JasperMobileAppDelegate sharedInstance] servers] count]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellAddAccount];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddAccount];
		}
		cell.textLabel.text = JSCustomLocalizedString(@"servers.new.account.title", nil);
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	
	if (editMode) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell
        ServerProfile *serverProfile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = serverProfile.alias;
        cell.detailTextLabel.text = serverProfile.serverUrl;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		}
		
		// Configure the cell
		ServerProfile *serverProfile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
		cell.textLabel.text = serverProfile.alias;
		cell.detailTextLabel.text = serverProfile.serverUrl;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
}

 // Override to support conditional editing of the table view.
 - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	 if (editMode == YES && [indexPath indexAtPosition: 1] < [[[JasperMobileAppDelegate sharedInstance] servers] count]) {
		return UITableViewCellEditingStyleDelete;
	 }
	 return UITableViewCellEditingStyleNone;
}

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	 if (editMode) {
		 if (editingStyle == UITableViewCellEditingStyleDelete) {
             JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
             
			 // Delete the row from the data source.
			 ServerProfile *serverProfile = [app.servers objectAtIndex:[indexPath indexAtPosition:1]];
             BOOL isProfileInUse = [[JasperMobileAppDelegate currentActiveServerProfile].alias isEqualToString:serverProfile.alias];
             
			 NSInteger index = [app.servers indexOfObject:serverProfile];
			 if (index >= 0) {
				 [app.servers removeObjectAtIndex:index];
                 [ServerProfile deletePasswordFromKeychain:[serverProfile profileID]];
                 [[app managedObjectContext] deleteObject:serverProfile];
                 [[app managedObjectContext] save:nil];
			 }
			 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
             
             if (isProfileInUse) {
                 // If the profile is currently in use then remove it
                 [app initProfileForRESTClient: nil];
             }
		 }
	 }
 }

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ServerProfile *serverProfile = nil;
	if ([indexPath indexAtPosition: 1] < [[[JasperMobileAppDelegate sharedInstance] servers] count]) {
		// Get the info of this client
		serverProfile = [[[JasperMobileAppDelegate sharedInstance] servers] objectAtIndex:[indexPath indexAtPosition:1]];
	}
	
	if (!editMode) {
		if (serverProfile == nil) return;
        JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
        
        if (serverProfile.askPassword.boolValue) {
            serverProfile.password = nil;
            [app disableTabBar];
            [app initProfileForRESTClient:serverProfile];
            [[JSUIAskPasswordDialog askPasswordDialogForProfile:serverProfile delegate:self updateMethod:@selector(updateProfilePassword)] show];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
            return;
        } else {
            [app enableTabBar];
        }
        
        [app initProfileForRESTClient:serverProfile];
		[[JasperMobileAppDelegate sharedInstance] configureServersDone:self];
		return;
	}
	
	[self editProfile: serverProfile];
}

- (void)updateProfilePassword {
    JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
    [app enableTabBar];
    [app.tabBarController setSelectedIndex:0];
}
		 
- (void)editProfile:(ServerProfile *)serverProfile {
	ServerSettingsViewController *vc  = [[ServerSettingsViewController alloc] initWithNibName: @"ServerSettingsViewController" bundle:nil];
	vc.currentServerProfile = serverProfile;
	vc.previousViewController = self;
	[self.navigationController pushViewController: vc animated: YES];
}

- (void)addServer:(ServerProfile *)serverProfile {
	[[[JasperMobileAppDelegate sharedInstance] servers] addObject:serverProfile];	
    [[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
}

- (void)updateServer:(ServerProfile *)serverProfile {
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

@end
