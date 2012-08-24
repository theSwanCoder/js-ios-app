//
//  JSUIFavoritesViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 21.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JasperMobileAppDelegate.h"
#import "JSUIFavoritesViewController.h"

@interface JSUIFavoritesViewController ()

@end

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

@end
