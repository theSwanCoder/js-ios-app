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
//  JSUILibraryViewController.m
//  Jaspersoft Corporation
//

#import "JSUILibraryViewController.h"
#import "JasperMobileAppDelegate.h"
#import "UIAlertView+LocalizedAlert.h"

@implementation JSUILibraryViewController

- (void)loadView {
    [super loadView];
}

- (void)updateTableContent {    
    if ([JSRESTBase isNetworkReachable] && resources == nil) {
		// load this view
        [JSUILoadingView showCancelableLoadingInView:self.view restClient:self.resourceClient delegate:self cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        JSConstants *constants = [JSConstants sharedInstance];
        NSArray *types = [NSArray arrayWithObjects:constants.WS_TYPE_REPORT_UNIT, constants.WS_TYPE_DASHBOARD, nil];
        [self.resourceClient resources:nil query:nil types:types recursive:YES limit:0 delegate:self];
    }
}

- (void)requestFinished:(JSOperationResult *)result {
    id type = [result.request.params objectForKey:@"type"];
    JSConstants *constants = [JSConstants sharedInstance];
    
    if (result.error != nil &&
        result.statusCode == 400 &&
        [type isKindOfClass:[NSArray class]] &&
        [type indexOfObject:constants.WS_TYPE_DASHBOARD] != NSNotFound) {
        NSArray *types = [NSArray arrayWithObjects:constants.WS_TYPE_REPORT_UNIT, nil];
        [self.resourceClient resources:nil query:nil types:types recursive:YES limit:0 delegate:self];
    } else {
        [super requestFinished:result];
    }
}

@end
