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
//  JSUIResourcePicker.m
//  Jaspersoft Corporation
//

#import "JSUIResourcePicker.h"
#import "UIAlertView+LocalizedAlert.h"

@implementation JSUIResourcePicker
@synthesize delegate;

- (id)initWithResourceType:(int)tp {
    self = [super init];
    type = tp;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self action:@selector(cancelPickClicked:)];
		
    self.navigationItem.rightBarButtonItem = cancelButton;	
}

- (IBAction)cancelPickClicked:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:TRUE];
	[self.delegate resourcePicked: nil];    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSResourceDescriptor *rd = (JSResourceDescriptor *)[self.resources objectAtIndex: [indexPath indexAtPosition:1]];
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    JSConstants *constants = [JSConstants sharedInstance];
    
    if ([rd.wsType isEqualToString:constants.WS_TYPE_FOLDER]) {    
        if (type == JSUIResourcePickerTypeResourcesOnly) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;		
        }
	} else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If the resource selected is a folder, navigate in the folder....
	JSResourceDescriptor *rd = [self.resources  objectAtIndex: [indexPath indexAtPosition:1]];
	
	if (rd != nil) {	
        if (type == JSUIResourcePickerTypeResourcesOnly && [rd.wsType isEqualToString:[JSConstants sharedInstance].WS_TYPE_FOLDER]) {
            JSUIResourcePicker *rvc = [[JSUIResourcePicker alloc] initWithNibName:nil bundle:nil];
            [rvc setResourceClient:self.resourceClient];
            [rvc setDescriptor:rd];
            [rvc setDelegate:self.delegate];
            [self.navigationController pushViewController: rvc animated: YES];
        } else {
            [self.navigationController dismissModalViewControllerAnimated:TRUE];
            [self.delegate resourcePicked:rd];
        }
	}    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    JSResourceDescriptor *rd = [self.resources  objectAtIndex: [indexPath indexAtPosition:1]];
    JSUIResourcePicker *rvc = [[JSUIResourcePicker alloc] initWithNibName:nil bundle:nil];
    [rvc setResourceClient:self.resourceClient];
    [rvc setDescriptor:rd];
    [rvc setDelegate:self.delegate];
    [self.navigationController pushViewController: rvc animated: YES];
}

- (void)requestFinished:(JSOperationResult *)res {
	if (res == nil) {
        [[UIAlertView localizedAlert:@"" message:@"error.readingresponse.dialog.msg" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
	} else {
		[self setResources: [NSMutableArray arrayWithCapacity:0]];
		  
        if (self.descriptor == nil && type == JSUIResourcePickerTypeFolderOnly)
        {
            JSResourceDescriptor *rootRd = [[JSResourceDescriptor alloc] init];
            [rootRd setName:@""];
            [rootRd setUriString:@"/"];
            [rootRd setLabel:@"<root>"];
            [self.resources addObject: rootRd];
        }
        
		// Show resources
		for (NSUInteger i = 0; i < res.objects.count; ++i) {
			JSResourceDescriptor *rd = [res.objects objectAtIndex:i];
            
            if (type == JSUIResourcePickerTypeFolderOnly) {
                if ([rd.wsType isEqualToString:[JSConstants sharedInstance].WS_TYPE_FOLDER]) {
                    [self.resources addObject:rd];
                }
            } else {
                [self.resources addObject:rd];
            }
        }
	}
	
	// Update the table...	
	[[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
    [JSUILoadingView hideLoadingView];    
}

@end
