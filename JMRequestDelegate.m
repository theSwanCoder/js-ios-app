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
//  JMRequestDelegate.m
//  Jaspersoft Corporation
//

static NSMutableArray *requestDelegatePool;
static void (^finalBlock)(void);

#import "JMRequestDelegate.h"
#import "JMCancelRequestPopup.h"
#import "JMFilter.h"

@interface JMRequestDelegate()
@property (nonatomic, strong) JSRequestFinishedBlock finishedBlock;
@end

@implementation JMRequestDelegate

+ (void)initialize
{
    requestDelegatePool = [NSMutableArray array];
}

+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock
{    
    JMRequestDelegate *requestDelegate = [[JMRequestDelegate alloc] init];
    requestDelegate.finishedBlock = finishedBlock;
    
    [requestDelegatePool addObject:requestDelegate];
    
    return requestDelegate;
}

+ (void)setFinalBlock:(void (^)(void))block
{
    finalBlock = block;
}

+ (BOOL)isRequestPoolEmpty
{
    return requestDelegatePool.count == 0;
}

+ (void)clearRequestPool
{
    [requestDelegatePool removeAllObjects];
    finalBlock = nil;
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    if (![result isSuccessful]) {
        [JMRequestDelegate clearRequestPool];
        [JMCancelRequestPopup dismiss];
        [JMFilter showAlertViewDialogForStatusCode:result.statusCode];
    } else if ([requestDelegatePool containsObject:self]) {
        self.finishedBlock(result);
        [requestDelegatePool removeObject:self];
        
        if ([JMRequestDelegate isRequestPoolEmpty]) {
            [JMCancelRequestPopup dismiss];
            if (finalBlock) {
                finalBlock();
                finalBlock = nil;
            }
        }
    }
}

@end
