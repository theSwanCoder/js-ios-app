/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMServersTableViewController.m
//  Jaspersoft Corporation
//

#import "JMServersTableViewController.h"
#import "JMAppUpdater.h"
#import "JMAskPasswordDialog.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMEditServerSegue = @"EditServer";

static NSInteger const kJMServersSection = 0;
static NSInteger const kJMFooterSection = 1;

@interface JMServersTableViewController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *servers;

- (NSIndexPath *)indexPathForTheNewServerCell;
@end

@implementation JMServersTableViewController
objection_requires(@"managedObjectContext")
inject_default_rotation()

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.infoButton.title = JMCustomLocalizedString(@"dialog.button.info", nil);
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDelegate:self];
    [segue.destinationViewController setServerToEdit:sender];
    [segue.destinationViewController setServers:self.servers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = JMCustomLocalizedString(@"view.servers", nil);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    self.servers = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];
    
    for (JMServerProfile *serverProfile in self.servers) {
        [serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:serverProfile.profileID]];
    }
}

- (void)viewDidUnload
{
    [self setInfoButton:nil];
    [self setServers:nil];
    [self setManagedObjectContext:nil];
    [super viewDidUnload];
}

#pragma mark - UIViewControllerEditing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        if (!self.servers.count) {
            [self performSegueWithIdentifier:kJMEditServerSegue sender:nil];
        } else {
            [self.tableView setEditing:YES animated:YES];
            
            // Add "New server account" table view cell
            NSIndexPath *indexPath = [self indexPathForTheNewServerCell];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }        
    } else {
        [self.tableView setEditing:NO animated:YES];
        
        NSIndexPath *indexPath = [self indexPathForTheNewServerCell];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kJMFooterSection] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kJMServersSection) {
        return self.tableView.isEditing ? self.servers.count + 1 : self.servers.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *serverCellIdentifier = @"ServerCell";
    static NSString *newServerCellIdentifier = @"NewServerCell";
    
    UITableViewCell *cell;
    
    if (self.tableView.isEditing && indexPath.row == self.servers.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:newServerCellIdentifier];
        cell.textLabel.text = JMCustomLocalizedString(@"servers.new.account.title", nil);
    } else {
        JMServerProfile *server = [self.servers objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:serverCellIdentifier];
        cell.textLabel.text = server.alias;
        cell.detailTextLabel.text = server.serverUrl;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kJMServersSection) {
        return JMCustomLocalizedString(@"servers.profile.title", nil);
    }
    
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.isEditing || indexPath.row == self.servers.count) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JMServerProfile *serverProfile = [self.servers objectAtIndex:indexPath.row];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults URLForKey:kJMDefaultsActiveServer];
        
        [self.servers removeObjectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:serverProfile];
        [self.managedObjectContext save:nil];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSURL *serverProfileID = [serverProfile.objectID URIRepresentation];
        NSURL *activeProfileID = [defaults URLForKey:kJMDefaultsActiveServer];
        
        // Check if profile to delete is an active
        if ([serverProfileID isEqual:activeProfileID]) {
            // Sets server profile to nil
            [JMUtils sendChangeServerProfileNotificationWithProfile:nil];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{   
    if (!self.tableView.isEditing && section == kJMFooterSection) {
        NSUInteger serversCount = self.servers.count;

        if (serversCount == 0) {
            return JMCustomLocalizedString(@"servers.profile.configure.help", nil);
        } else if(serversCount == 1) {
            return  JMCustomLocalizedString(@"servers.profile.configure.tips", nil);
        }
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing || indexPath.row == self.servers.count) {
        JMServerProfile *serverProfile = indexPath.row < self.servers.count ? [self.servers objectAtIndex:indexPath.row] : nil;
        [self performSegueWithIdentifier:kJMEditServerSegue sender:serverProfile];
    } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        JMServerProfile *serverProfile = [self.servers objectAtIndex:indexPath.row];
        
        if (serverProfile.askPassword.boolValue) {
            serverProfile.password = nil;
            [[JMAskPasswordDialog askPasswordDialogForServerProfile:serverProfile] show];
        } else {
            [JMUtils sendChangeServerProfileNotificationWithProfile:serverProfile];
        }
    }
}

#pragma mark - Actions

- (IBAction)applicationInfo:(id)sender
{
    NSString *message = JMCustomLocalizedString(@"servers.info", nil);
    message = [NSString stringWithFormat:message, [JMAppUpdater latestAppVersion]];
    
    [[UIAlertView localizedAlertWithTitle:nil
                         message:message
                        delegate:nil
               cancelButtonTitle:@"dialog.button.ok"
               otherButtonTitles:nil] show];
}

#pragma mark - JMServerSettingsTableViewControllerDelegate

- (void)updateWithServerProfile:(JMServerProfile *)serverProfile
{
    NSUInteger index = [self.servers indexOfObject:serverProfile];
    NSIndexPath *indexPath;
    
    if (index != NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.servers replaceObjectAtIndex:index withObject:serverProfile];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        indexPath = [NSIndexPath indexPathForRow:self.servers.count inSection:0];
        [self.servers addObject:serverProfile];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Private

- (NSIndexPath *)indexPathForTheNewServerCell
{
    return [NSIndexPath indexPathForRow:self.servers.count inSection:0];
}

@end
