//
//  JMServersTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/8/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMServersTableViewController.h"
#import "JMLocalization.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JMServerProfile+Helpers.h"
#import <CoreData/CoreData.h>
#import <Objection-iOS/Objection.h>

@interface JMServersTableViewController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSMutableArray *servers;
@end

@implementation JMServersTableViewController
objection_requires(@"managedObjectContext");

#pragma mark - Initialization

- (void)awakeFromNib
{
    [[JSObjection defaultInjector] injectDependencies:self];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editServers:)];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"alias" ascending:YES]];
    self.servers = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];

    for (JMServerProfile *server in self.servers) {
        server.password = [JMServerProfile passwordFromKeychain:[server encodedProfileID]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ServerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    JMServerProfile *server = [self.servers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = server.alias;
    cell.detailTextLabel.text = server.serverUrl;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return JMCustomLocalizedString(@"servers.profile.title", nil);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Action

- (IBAction)editServers:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.doneButton;
    // TODO: need implementation
    
    if (!self.servers.count) {
        // Redirect to Add New Server directly
        
    } else {
        [self.tableView setEditing:YES animated:YES];
    }
}

- (IBAction)doneEditing:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.editButton;
    // TODO: need implementation
    
    [self.tableView setEditing:NO animated:YES];
}

- (IBAction)applicationInfo:(id)sender
{
    NSString *message = JMCustomLocalizedString(@"servers.info", nil);
    // TODO: replace with normal version from app updater
    message = [NSString stringWithFormat:message, @1.6];
    [[UIAlertView localizedAlert:nil
                         message:message
                        delegate:nil
               cancelButtonTitle:@"dialog.button.ok"
               otherButtonTitles:nil] show];
}

@end
