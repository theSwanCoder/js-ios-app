//
//  JSUIFavoritesViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 21.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JasperMobileAppDelegate.h"
#import "JSUIFavoritesViewController.h"

@interface JSUIFavoritesViewController ()

@end

@implementation JSUIFavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    // Refresh table if resource was removed from favorites inside
    if ([[JasperMobileAppDelegate sharedInstance].favorites isChangesWasMade]) {
        self.resources = [[JasperMobileAppDelegate sharedInstance].favorites wrappersFromFavorites];
    
        [self.tableView beginUpdates];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resources = [[JasperMobileAppDelegate sharedInstance].favorites wrappersFromFavorites];
	// Do any additional setup after loading the view.
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

@end
