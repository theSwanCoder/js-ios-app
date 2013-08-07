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
//  JMServerSettingsTableViewController.m
//  Jaspersoft Corporation
//

#import "JMServerSettingsTableViewController.h"
#import "JMFavoritesUtil.h"
#import "JMLocalization.h"
#import "UIAlertView+LocalizedAlert.h"
#import <Objection-iOS/Objection.h>

// Indexes for cells
#define kJMNameCell 0
#define kJMURLCell 1
#define kJMOrganizationCell 2
#define kJMUsernameCell 3
#define kJMPasswordCell 4
#define kJMAskPasswordCell 5

static NSString * const kJMTextFieldCellIdentifier = @"TextFieldCell";
static NSString * const kJMSecureTextFieldCellIdentifier = @"SecureTextFieldCell";
static NSString * const kJMSwitchCellIdentifier = @"SwitchCell";

static NSString * const kJMTitleKey = @"title";
static NSString * const kJMValueKey = @"value";
static NSString * const kJMPlaceholderKey = @"placeholder";
static NSString * const kJMValidationBlockKey = @"validationBlock";
static NSString * const kJMCellIdentifierKey = @"cellIdentifier";
static NSString * const kJMSelectorKey = @"selector";
// Tracking state of cell to avoid calculation of frame multiple times (for label and text field)
static NSString * const kJMWasConfiguredKey = @"wasConfigured";

static NSInteger const kJMTextFieldLeftMargin = 20;
static NSInteger const kJMTextFieldRightMargin = 10;

// Validates specified string value.
// returns YES if value is valid, otherwise returns NO
typedef BOOL (^JMValidationBlock)(NSString *value, NSString **errorMessage);

@interface JMServerSettingsTableViewController ()
// Containts different properties for cell: identifier, label name, placeholder / value
// for component (can be text field or switch), validation block and indicator, if cell
// was configured
@property (nonatomic, strong) NSDictionary *cellsProperties;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) JMFavoritesUtil *favoritesUtil;
@end

@implementation JMServerSettingsTableViewController
objection_requires(@"managedObjectContext", @"favoritesUtil");

#pragma mark - Accessors

- (NSDictionary *)cellsProperties
{
    if (!_cellsProperties) {
        _cellsProperties = @{
            @kJMNameCell : [@{
                kJMTitleKey : @"servers.name.label",
                kJMPlaceholderKey : @"servers.myserver.label",
                kJMValueKey : self.serverToEdit.alias ?: @"",
                kJMCellIdentifierKey : kJMTextFieldCellIdentifier,
                kJMSelectorKey : [NSValue valueWithPointer:@selector(setAlias:)],
                kJMValidationBlockKey : ^(NSString *value, NSString **errorMessage) {
                    // Check if alias is nil or empty
                    if (!value || !value.length) {
                        *errorMessage = @"servers.name.errmsg.empty";
                        return NO;
                    }
                     
                    // Check if alias is unique
                    for (JMServerProfile *server in self.servers) {
                        if (server != self.serverToEdit && [server.alias isEqualToString:value]) {
                            *errorMessage = @"servers.name.errmsg.exists";
                            return NO;
                        }
                    }
                     
                    return YES;
                }
            } mutableCopy],
            
            @kJMURLCell : [@{
                kJMTitleKey : @"servers.url.label",
                kJMPlaceholderKey : @"servers.url.tip",
                kJMValueKey : self.serverToEdit.serverUrl ?: @"",
                kJMCellIdentifierKey : kJMTextFieldCellIdentifier,
                kJMSelectorKey : [NSValue valueWithPointer:@selector(setServerUrl:)],
                kJMValidationBlockKey : ^(NSString *value, NSString **errorMessage) {
                    NSURL *url = [NSURL URLWithString:value];
                    if (!url || !url.scheme || !url.host) {
                        *errorMessage = @"servers.url.errmsg";
                        return NO;
                    }
                     
                    return YES;
                }
            } mutableCopy],
             
            @kJMOrganizationCell : [@{
                kJMTitleKey : @"servers.orgid.label",
                kJMPlaceholderKey : @"servers.orgid.tip",
                kJMValueKey : self.serverToEdit.organization ?: @"",
                kJMCellIdentifierKey : kJMTextFieldCellIdentifier,
                kJMSelectorKey : [NSValue valueWithPointer:@selector(setOrganization:)]
            } mutableCopy],
             
            @kJMUsernameCell : [@{
                kJMTitleKey : @"servers.username.label",
                kJMPlaceholderKey : @"servers.username.tip",
                kJMValueKey : self.serverToEdit.username ?: @"",
                kJMCellIdentifierKey : kJMTextFieldCellIdentifier,
                kJMSelectorKey : [NSValue valueWithPointer:@selector(setUsername:)],
                kJMValidationBlockKey : ^(NSString *value, NSString **errorMessage) {
                    if (!value || !value.length) {
                        *errorMessage = @"servers.username.errmsg.empty";
                        return NO;
                    }
                     
                    return YES;
                }
            } mutableCopy],
             
            @kJMPasswordCell : [@{
                kJMTitleKey : @"servers.password.label",
                kJMPlaceholderKey : @"servers.password.tip",
                kJMValueKey : self.serverToEdit.password ?: @"",
                kJMCellIdentifierKey : kJMSecureTextFieldCellIdentifier,
                kJMSelectorKey : [NSValue valueWithPointer:@selector(setPassword:)]
            } mutableCopy],
             
            @kJMAskPasswordCell : [@{
                kJMTitleKey : @"servers.askpassword.label",
                kJMValueKey : self.serverToEdit.askPassword ?: @NO,
                kJMCellIdentifierKey : kJMSwitchCellIdentifier,
                kJMSelectorKey : [NSValue valueWithPointer:@selector(setAskPassword:)]
            } mutableCopy],
        };
    }
    
    return _cellsProperties;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.serverToEdit) {
        self.title = JMCustomLocalizedString(@"servers.title.new", nil);
    } else {
        self.title = JMCustomLocalizedString(@"servers.title.edit", nil);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellsProperties.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return JMCustomLocalizedString(@"servers.profile.details.title", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *cellProperties = [self.cellsProperties objectForKey:@(indexPath.row)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellProperties[kJMCellIdentifierKey]];
    
    // Check if cell wasn't alredy configured
    BOOL cellWasConfigured = [cellProperties[kJMWasConfiguredKey] boolValue];
    if (cellWasConfigured) return cell;
    
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = JMCustomLocalizedString(cellProperties[kJMTitleKey], nil);
    [label sizeToFit];
    
    if (indexPath.row != kJMAskPasswordCell) {
        UITextField *textField = (UITextField *) [cell viewWithTag:2];
        
        CGRect newTextFieldFrame = CGRectMake(label.frame.size.width + kJMTextFieldLeftMargin,
                                          textField.frame.origin.y,
                                          cell.frame.size.width - label.frame.size.width - kJMTextFieldLeftMargin - kJMTextFieldRightMargin,
                                          textField.frame.size.height);
        textField.frame = newTextFieldFrame;
        
        if (indexPath.row != kJMPasswordCell || !self.serverToEdit.askPassword.boolValue) {
            textField.placeholder = JMCustomLocalizedString(cellProperties[kJMPlaceholderKey], nil);
            textField.text = cellProperties[kJMValueKey];
        }
        
        textField.delegate = self;
    } else {
        UISwitch *askPasswordSwitch = (UISwitch *) [cell viewWithTag:2];
        askPasswordSwitch.on = [cellProperties[kJMValueKey] boolValue];
        [self askPasswordSwitchToggled:askPasswordSwitch];
    }
    
    cellProperties[kJMWasConfiguredKey] = @YES;
    
    return cell;
}

#pragma mark - Actions

- (IBAction)valueChanged:(id)sender
{
    // Update value for cell
    NSIndexPath *indexPath = [self indexPathForTextField:sender];
    NSMutableDictionary *cellProperties = self.cellsProperties[@(indexPath.row)];
    cellProperties[kJMValueKey] = [sender text];
}

- (IBAction)askPasswordSwitchToggled:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kJMPasswordCell inSection:0];
    UITableViewCell *passwordCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *label = (UILabel *) [passwordCell viewWithTag:1];
    UITextField *textField = (UITextField *) [passwordCell viewWithTag:2];
    
    if (![sender isOn]) {
        textField.enabled = YES;
        textField.textColor = [UIColor blackColor];
        label.textColor = textField.textColor;
    } else {
        textField.enabled = NO;
        textField.textColor = [UIColor lightGrayColor];
        label.textColor = textField.textColor;
    }
    
    // Update value for ask password cell
    NSMutableDictionary *cellProperties = self.cellsProperties[@kJMAskPasswordCell];
    cellProperties[kJMValueKey] = @([sender isOn]);    
}

// Modifies existing or creates new server profile
- (IBAction)save:(id)sender
{
    // Check if new server profile should be created
    if (!self.serverToEdit) {
        self.serverToEdit = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:self.managedObjectContext];
    }
    
    NSArray *allKeys = [[self.cellsProperties allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSNumber *key in allKeys) {
        NSDictionary *cellProperties = self.cellsProperties[key];
        id value = cellProperties[kJMValueKey];
        
        JMValidationBlock validation = cellProperties[kJMValidationBlockKey];
        NSString *errorMessage;
        
        // Perform validation for value and check if it's invalid
        if (validation && !validation(value, &errorMessage)) {
            // Show error message. Problem here that we can show error message
            // only for 1 property at a time
            [[UIAlertView localizedAlertWithTitle:nil
                                         message:errorMessage
                                        delegate:nil
                               cancelButtonTitle:@"dialog.button.ok"
                               otherButtonTitles:nil] show];
            
            // Check if server profile is new
            if (self.serverToEdit.isInserted) {
                // Forces to recreate object entity in managed object context again
                self.serverToEdit = nil;
            }
            
            // Rollback all changes
            [self.managedObjectContext rollback];
            
            break;
        }
        
        // Apply value (if validation step was successfully passed) to server
        // profile by selector (in this case selector is just a setter). Here
        // NSInvocation was used becase "performSelector:withObject:" produces
        // memory leak warning
        SEL selector = [cellProperties[kJMSelectorKey] pointerValue];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.serverToEdit methodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = self.serverToEdit;
        [invocation setArgument:&value atIndex:2];
        [invocation invoke];        
    }
    
    // Check if changes was not rollbacked
    if ([self.managedObjectContext hasChanges]) {
        // Save changes
        [self.managedObjectContext save:nil];
        // Store password for server profile in keychain
        [JMServerProfile storePasswordInKeychain:self.serverToEdit.password profileID:self.serverToEdit.profileID];
        // Update previous view controller with modified server profile
        [self.delegate updateWithServerProfile:self.serverToEdit];
        // Indicate that Favorites View Controller should refresh data
        self.favoritesUtil.needsToRefreshFavorites = YES;
        // Go to previous view controller
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField.returnKeyType == UIReturnKeyNext) {
        NSIndexPath *indexPath = [self indexPathForTextField:textField];
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
        
        if (nextCell) {
            [textField resignFirstResponder];
            [[nextCell viewWithTag:2] becomeFirstResponder];
        }
    } else {
        [textField resignFirstResponder];
    }
    
	return YES;
}

#pragma mark - Private

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
    return [self.tableView indexPathForCell:(UITableViewCell *)textField.superview.superview];
}

@end
