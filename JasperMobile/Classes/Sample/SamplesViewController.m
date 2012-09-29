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
//  SamplesViewController.m
//  Jaspersoft Corporation
//

#import "SamplesViewController.h"
#import "JasperMobileAppDelegate.h"
#import "Sample1.h"
#import "Sample2.h"
#import "Sample3.h"
#import "Sample4.h"
#import "Sample5.h"
#import "Sample6.h"

@implementation SamplesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    samples = [[NSMutableArray alloc] initWithCapacity:0];
    
    [samples addObject:@"Repository view"];
    [samples addObject:@"Resource picker"];
    [samples addObject:@"Get resource info"];
    [samples addObject:@"Create a folder"];
    [samples addObject:@"Load an image resource"];
    [samples addObject:@"Delete an object"];
    
    // update table...
    [[self tableView] beginUpdates];
	[[self tableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[[self tableView] endUpdates];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return (CGFloat)0.f;
}



// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (samples != nil)
	{
		return [samples count];
	}
	
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.textLabel.text =  [samples objectAtIndex: [indexPath indexAtPosition:1]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;		
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath indexAtPosition:1] == 0)
    {
        [Sample1 runSample: [[ JasperMobileAppDelegate sharedInstance] client]
        parentViewController: self];
    }
    else if ([indexPath indexAtPosition:1] == 1)
    {
        [Sample2 runSample: [[ JasperMobileAppDelegate sharedInstance] client]
        parentViewController: self];
    }
    else if ([indexPath indexAtPosition:1] == 2)
    {
        [Sample3 runSample: [[ JasperMobileAppDelegate sharedInstance] client]
         parentViewController: self];
    }
    else if ([indexPath indexAtPosition:1] == 3)
    {
        [Sample4 runSample: [[ JasperMobileAppDelegate sharedInstance] client]
      parentViewController: self];
    }
    else if ([indexPath indexAtPosition:1] == 4)
    {
        [Sample5 runSample: [[ JasperMobileAppDelegate sharedInstance] client]
      parentViewController: self];
    }
    else if ([indexPath indexAtPosition:1] == 5)
    {
        [Sample6 runSample: [[ JasperMobileAppDelegate sharedInstance] client]
      parentViewController: self];
    }	    
}



@end
