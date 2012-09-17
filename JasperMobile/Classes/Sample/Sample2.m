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
//  Sample2.m
//  Jaspersoft Corporation
//

#import "Sample2.h"


@implementation Sample2

@synthesize parentController;


+(void)runSample:(JSClient *)client parentViewController: (UIViewController *)controller
{
    // 1. Create a new resource picker
    JSUIResourcePicker *resourcePicker = [[JSUIResourcePicker alloc] initWithResourceType: JSUIResourcePickerTypeAllResources];    
    
    // 2. Set the client (the class which contains the server settings)
    [resourcePicker setClient: client];
    
    // 3. Set the delegated
    Sample2 *delegate = [[Sample2 alloc] init];
    [delegate setParentController: controller];
     
    [resourcePicker setDelegate:delegate];
    [delegate release];
    
    // 4. Prepare a navigation controller to display the picker as modal view...
    UINavigationController *picker = [[UINavigationController alloc] initWithRootViewController:resourcePicker];
    
    // Push the new view
    [[controller navigationController] presentModalViewController:picker animated:TRUE];
    
    // Force an update.
    [resourcePicker updateTableContent];
    
   // [resourcePicker release];
    [picker release];
    

        
}

-(void)resourcePicked:(JSResourceDescriptor *)rd
{
    NSString *msg;
    
    if (rd == nil) {
        msg = @"No resource selected";
    }
    else
    {
        msg = [NSString stringWithFormat:@"Selected resource:\n%@", [rd uri]];  
    }
    // Show the selected resource...
    UIAlertView *uiView =[[[UIAlertView alloc] initWithTitle:@"" message: msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    [uiView show];
        
}

@end
