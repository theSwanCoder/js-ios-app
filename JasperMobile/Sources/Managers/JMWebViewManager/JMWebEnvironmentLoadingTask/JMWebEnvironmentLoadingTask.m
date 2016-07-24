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
//  JMWebEnvironmentLoadingTask.h
//  TIBCO JasperMobile
//

#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptEvent.h"
#import "JMJavascriptRequestExecutor.h"

@interface JMWebEnvironmentLoadingTask()
@property (nonatomic, strong) JMJavascriptRequestExecutor *requestExecutor;
@property (nonatomic, strong) NSString *HTMLString;
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation JMWebEnvironmentLoadingTask

#pragma mark - Life Cycle

- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             HTMLString:(NSString *)HTMLString
                                baseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _requestExecutor = requestExecutor;
        _HTMLString = HTMLString;
        _baseURL = baseURL;
        self.state = JMAsyncTaskStateReady;
    }
    return self;
}

+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             HTMLString:(NSString *)HTMLString
                                baseURL:(NSURL *)baseURL
{
    return [[self alloc] initWithRequestExecutor:requestExecutor
                                      HTMLString:HTMLString
                                         baseURL:baseURL];
}

#pragma mark - Overridden methods NSOperation

- (void)main
{
    __weak __typeof(self) weakSelf = self;
    JMJavascriptEvent *event = [JMJavascriptEvent eventWithIdentifier:@"DOMContentLoaded"
                                                             listener:self
                                                             callback:^(JMJavascriptResponse *response, NSError *error) {
                                                                 JMLog(@"Event was received: DOMContentLoaded");
                                                                 __typeof(self) strongSelf = weakSelf;
                                                                 strongSelf.state = JMAsyncTaskStateFinished;
                                                                 [strongSelf.requestExecutor removeListener:strongSelf];
                                                             }];
    [self.requestExecutor addListenerWithEvent:event];
    [self.requestExecutor startLoadHTMLString:self.HTMLString
                                      baseURL:self.baseURL];
}

@end