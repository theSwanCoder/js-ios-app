/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMAsyncTask.m
//  TIBCO JasperMobile
//

#import "JMAsyncTask.h"
#import "JMUtils.h"

@implementation JMAsyncTask

- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = JMAsyncTaskStateReady;
    }
    return self;
}

#pragma mark - Custom Accessors

- (void)setState:(JMAsyncTaskState)state
{
    [self willChangeValueForKey:[self stringValueForState:state]];
    _state = state;
    [self didChangeValueForKey:[self stringValueForState:state]];
}

- (NSString *)stringValueForState:(JMAsyncTaskState)state
{
    NSString *stringValue = @"is";
    switch (state) {
        case JMAsyncTaskStateReady: {
            stringValue = [stringValue stringByAppendingString:@"Ready"];
            break;
        }
        case JMAsyncTaskStateExecuting: {
            stringValue = [stringValue stringByAppendingString:@"Executing"];
            break;
        }
        case JMAsyncTaskStateFinished: {
            stringValue = [stringValue stringByAppendingString:@"Finished"];
            break;
        }
    }
    return stringValue;
}

#pragma mark - Overridded Properties

- (BOOL)isReady
{
    BOOL isReady = super.isReady && (self.state == JMAsyncTaskStateReady);
    return isReady;
}

- (BOOL)isExecuting
{
    BOOL isExecuting = (self.state == JMAsyncTaskStateExecuting);
    return isExecuting;
}

- (BOOL)isFinished
{
    BOOL isFinished = (self.state == JMAsyncTaskStateFinished);
    return isFinished;
}

#pragma mark - Overridded Methods

- (void)start
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (self.isCancelled) {
        self.state = JMAsyncTaskStateFinished;
        return;
    }

    [self main];
    self.state = JMAsyncTaskStateExecuting;
}

- (void)cancel
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.state = JMAsyncTaskStateFinished;
}

@end