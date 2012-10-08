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
//  Sample1.m
//  Jaspersoft Corporation
//

#import "Sample1.h"
#include "JSUIRepositoryViewController.h"


@implementation Sample1


+(void)runSample:(JSClient *)client parentViewController: (UIViewController *)controller
{
    // 1. Create a new resource view
    JSUIRepositoryViewController *resourceView = [[JSUIRepositoryViewController alloc] init];
    
    // 2. Set the client (the class which contains the server settings)
    [resourceView setClient: client];
    
    // Push the new view
    [[controller navigationController] pushViewController:resourceView animated: TRUE];
    
    // Force an update.
    [resourceView updateTableContent];
    
    [resourceView release];
}


@end
