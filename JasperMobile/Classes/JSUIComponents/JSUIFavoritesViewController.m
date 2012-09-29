/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
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
//  Jaspersoft Corporation
//

#import "JasperMobileAppDelegate.h"
#import "JSUIFavoritesViewController.h"


@implementation JSUIFavoritesViewController

@synthesize editDoneButton;
@synthesize editMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.editMode = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    // Refresh table if resource was removed from favorites inside
    
    self.editMode = NO;
    self.resources = [[JasperMobileAppDelegate sharedInstance].favorites wrappersFromFavorites];
    
    self.editDoneButton.title = @"Edit";
    self.editDoneButton.action = @selector(editClicked:);
    
    [[self tableView] setEditing:self.editMode animated:YES];
    [self.tableView reloadData];
    [self enableDisableEditDoneButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"view.favorites", @"");
    self.editDoneButton = [[[UIBarButtonItem alloc] initWithTitle: @"Edit"
                                                            style: UIBarButtonItemStylePlain
                                                           target:self action:@selector(editClicked:)] autorelease];
    self.navigationItem.rightBarButtonItem = self.editDoneButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editMode) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            JSResourceDescriptor *resource = [self.resources objectAtIndex:[indexPath indexAtPosition:1]];
            [resource retain];
            [self.resources removeObjectAtIndex:[indexPath indexAtPosition:1]];                
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[JasperMobileAppDelegate sharedInstance].favorites removeFromFavorites:resource];
            [resource release];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resources.count ?: 0;
}

- (void)dealloc {
    [editDoneButton release];
    if (resources) {
        [resources release];
        resources = nil;
    }
    [super dealloc];
}

- (void)editClicked:(id)sender {
    self.editDoneButton.title = @"Done";
	self.editDoneButton.action = @selector(doneClicked:);
	self.editMode = YES;
    [[self tableView] setEditing:true animated:YES];   
}

- (void)doneClicked:(id)sender {
	
	self.editDoneButton.title = @"Edit";
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

- (void)updateTableContent {
    // Empty method for overriding base method
    // Here we don't need automatically load resources if resources == nil
    // also this allows to view favorites offline (only view)
}

@end
