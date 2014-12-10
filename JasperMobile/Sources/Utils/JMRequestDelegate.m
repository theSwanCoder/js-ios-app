#import "JMRequestDelegate.h"

/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMRequestDelegate.m
//  TIBCO JasperMobile
//

static NSMutableArray *requestDelegatePool;
static JMRequestDelegateFinalBlock finalBlock;
__weak static UIViewController *viewControllerToDismiss;

#import "JMCancelRequestPopup.h"
#import "UIAlertView+Additions.h"
#import "JMUtils.h"
#import "RestKit/RKErrors.h"


@interface JMRequestDelegate()
@property (nonatomic, copy) JSRequestFinishedBlock finishedBlock;
@property (nonatomic, copy) JSRequestFinishedBlock errorBlock;
@property (nonatomic, weak) id <JSRequestDelegate> delegate;
@property (nonatomic, assign) BOOL showAlerts;

@end

@implementation JMRequestDelegate

#pragma mark - Class Methods

+ (void)initialize
{
    requestDelegatePool = [NSMutableArray array];
}

+ (void)setFinalBlock:(JMRequestDelegateFinalBlock)block
{
    finalBlock = block;
}

+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock
{
    return [self requestDelegateForFinishBlock:finishedBlock errorBlock:nil];
}

+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock errorBlock:(JSRequestFinishedBlock)errorBlock
{
    return [self requestDelegateForFinishBlock:finishedBlock errorBlock:errorBlock viewControllerToDismiss:nil];
}

+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock viewControllerToDismiss:(UIViewController *)viewController
{
    return [self requestDelegateForFinishBlock:finishedBlock errorBlock:nil viewControllerToDismiss:viewController];
}

+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock errorBlock:(JSRequestFinishedBlock)errorBlock viewControllerToDismiss:(UIViewController *)viewController
{
    return [self requestDelegateForFinishBlock:finishedBlock errorBlock:errorBlock viewControllerToDismiss:viewController showAlerts:YES];
}

+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock errorBlock:(JSRequestFinishedBlock)errorBlock viewControllerToDismiss:(UIViewController *)viewController showAlerts:(BOOL)showAlerts
{
    JMRequestDelegate *requestDelegate = [[JMRequestDelegate alloc] init];
    requestDelegate.finishedBlock = finishedBlock;
    requestDelegate.errorBlock = errorBlock;
    requestDelegate.showAlerts = showAlerts;
    requestDelegate.checkStatusCode = YES;

    viewControllerToDismiss = viewController;
    
    [requestDelegatePool addObject:requestDelegate];
    [JMUtils showNetworkActivityIndicator];
    
    return requestDelegate;
}

+ (JMRequestDelegate *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate
{
    JMRequestDelegate *requestDelegate = [[JMRequestDelegate alloc] init];
    requestDelegate.delegate = delegate;

    [requestDelegatePool addObject:requestDelegate];
    [JMUtils showNetworkActivityIndicator];

    return requestDelegate;
}

+ (JMRequestDelegate *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate viewControllerToDismiss:(UIViewController *)viewController
{
    viewControllerToDismiss = viewController;
    return [self checkRequestResultForDelegate:delegate];
}

+ (BOOL)isRequestPoolEmpty
{
    return requestDelegatePool.count == 0;
}

+ (void)clearRequestPool
{
    [requestDelegatePool removeAllObjects];
    finalBlock = nil;
    viewControllerToDismiss = nil;
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    if (result && (![result isSuccessful] && self.checkStatusCode)) {
        if ([requestDelegatePool containsObject:self] && self.errorBlock) {
            self.errorBlock(result);
        }

        [JMRequestDelegate clearRequestPool];
        [JMCancelRequestPopup dismiss];

        if (self.showAlerts) {
            NSString *title;
            NSString *message;
            
            if (result.statusCode) {
                title = @"error.readingresponse.dialog.msg";
                message = [NSString stringWithFormat:@"error.http.%li", (long)result.statusCode];
            } else if ([result.error.domain isEqualToString:RKErrorDomain] && result.error.code == RKRequestConnectionTimeoutError) {
                title = @"error.readingresponse.dialog.msg";
                message = @"error.http.504";
            } else {
                switch (result.error.code) {
                    case NSURLErrorUserCancelledAuthentication:
                    case NSURLErrorUserAuthenticationRequired:
                        title = @"error.authenication.dialog.title";
                        message = @"error.authenication.dialog.msg";
                        break;
                        
                    case NSURLErrorCannotFindHost:
                        title = @"error.unknownhost.dialog.title";
                        message = @"error.unknownhost.dialog.msg" ;
                        break;
                    
                    default:
                        title = @"error.noconnection.dialog.title";
                        message = @"error.noconnection.dialog.msg";
                }
            }
        
            [[UIAlertView localizedAlertWithTitle:title
                                          message:message
                                         delegate:JMRequestDelegate.class
                                cancelButtonTitle:@"dialog.button.ok"
                                otherButtonTitles:nil] show];
        }
    } else if ([requestDelegatePool containsObject:self]) {
        if (self.finishedBlock) {
            self.finishedBlock(result);
        }

        if (self.delegate) {
            [self.delegate requestFinished:result];
        }

        [requestDelegatePool removeObject:self];
        
        if ([JMRequestDelegate isRequestPoolEmpty]) {
            [JMCancelRequestPopup dismiss];
            viewControllerToDismiss = nil;

            if (finalBlock) {
                finalBlock();
                finalBlock = nil;
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (viewControllerToDismiss.navigationController) {
        [viewControllerToDismiss.navigationController popViewControllerAnimated:YES];
        viewControllerToDismiss = nil;
    }
}

@end
