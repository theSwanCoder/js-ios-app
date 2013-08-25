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
//  JMFilter.m
//  Jaspersoft Corporation
//

#import "JMFilter.h"
#import "JMCancelRequestPopup.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"

static JMFilter * filterDelegate;

@interface JMFilter()
@property (nonatomic, weak) id <JSRequestDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewControllerToDismiss;
@end

@implementation JMFilter

#pragma mark - Class Methods

+ (void)checkNetworkReachabilityForBlock:(void (^)(void))block viewControllerToDismiss:(id)viewController
{
    if (![JMUtils isNetworkReachable]) {
        [JMCancelRequestPopup dismiss];
        
        filterDelegate = [[JMFilter alloc] init];
        filterDelegate.viewControllerToDismiss = viewController;
        
        [[UIAlertView localizedAlertWithTitle:@"error.noconnection.dialog.title"
                             message:@"error.noconnection.dialog.msg"
                            delegate:filterDelegate
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];
    } else {
        [JMUtils showNetworkActivityIndicator];
        block();
	}
}

+ (JMFilter *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate
{
    JMFilter *filter = [[JMFilter alloc] init];
    filter.delegate = delegate;
    return filter;
}

+ (void)showAlertViewDialogForStatusCode:(NSInteger)statusCode
{
    [[UIAlertView localizedAlertWithTitle:@"error.readingresponse.dialog.msg"
                                  message:[NSString stringWithFormat:@"error.http.%i", statusCode]
                                 delegate:nil
                        cancelButtonTitle:@"dialog.button.ok"
                        otherButtonTitles:nil] show];
}


#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    [JMCancelRequestPopup dismiss];
    
    if ([result isSuccessful]) {
        if (self.delegate) [self.delegate requestFinished:result];
    } else {
        [JMFilter showAlertViewDialogForStatusCode:result.statusCode];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.viewControllerToDismiss.navigationController) {
        [self.viewControllerToDismiss.navigationController popViewControllerAnimated:YES];
    }
    
    filterDelegate = nil;
}

@end
