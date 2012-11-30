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
//  JSUIFavoritesViewController.m
//  JasperMobile
//

#import "JasperMobileAppDelegate.h"
#import "JSUIFavoritesViewController.h"

@interface JSUIFavoritesViewController()

@property (nonatomic, retain) NSString *localizedTitleDone;
@property (nonatomic, retain) NSString *localizedTitleEdit;

@end

@implementation JSUIFavoritesViewController

@synthesize editDoneButton = _editDoneButton;
@synthesize editMode = _editMode;
@synthesize localizedTitleDone = _localizedTitleDone;
@synthesize localizedTitleEdit = _localizedTitleEdit;

- (void)viewWillAppear:(BOOL)animated {
    // Refresh table if resource was removed from favorites inside
    self.resources = [[JasperMobileAppDelegate sharedInstance].favorites wrappersFromFavorites] ?: [NSArray array];
    self.editDoneButton.title = self.localizedTitleEdit;
    self.editDoneButton.action = @selector(editClicked:);
    self.navigationItem.title = self.resourceClient.serverProfile.alias;
    
    [[self tableView] setEditing:self.editMode animated:YES];
    [self.tableView reloadData];
    [self enableDisableEditDoneButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.localizedTitleDone = NSLocalizedString(@"dialog.button.done", nil);
    self.localizedTitleEdit = NSLocalizedString(@"dialog.button.edit", nil);
    self.editMode = NO;
    self.title = NSLocalizedString(@"view.favorites", nil);
    self.editDoneButton = [[UIBarButtonItem alloc] initWithTitle:self.localizedTitleEdit
                                                            style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(editClicked:)];
    self.navigationItem.rightBarButtonItem = self.editDoneButton;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editMode) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            JSResourceDescriptor *resource = [self.resources objectAtIndex:[indexPath indexAtPosition:1]];
            [self.resources removeObjectAtIndex:[indexPath indexAtPosition:1]];                
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[JasperMobileAppDelegate sharedInstance].favorites removeFromFavorites:resource];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resources.count ?: 0;
}

- (void)editClicked:(id)sender {
    self.editDoneButton.title = self.localizedTitleDone;
	self.editDoneButton.action = @selector(doneClicked:);
	self.editMode = YES;
    [[self tableView] setEditing:true animated:YES];   
}

- (void)doneClicked:(id)sender {
	self.editDoneButton.title = self.localizedTitleEdit;
	self.editDoneButton.action = @selector(editClicked:);
	self.editMode = NO;	
	[[self tableView] setEditing:false animated:YES];
    [self enableDisableEditDoneButton];
}

- (void)enableDisableEditDoneButton {    
    if (self.resources.count) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

@end
