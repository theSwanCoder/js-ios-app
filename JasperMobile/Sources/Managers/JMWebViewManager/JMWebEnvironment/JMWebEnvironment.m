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
//  JMWebEnvironment.m
//  TIBCO JasperMobile
//

#import "JMWebEnvironment.h"
#import "JMUtils.h"
#import "JMReportChartType.h"

@interface JMWebEnvironment()

@end

@implementation JMWebEnvironment

#pragma mark - Public API

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    // imlement in childs
}

#pragma mark - Helpers

- (void)verifyJasperMobileEnableWithCompletion:(void(^ __nonnull)(BOOL isEnable))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSString *jsCommand = @"typeof(JasperMobile);";
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isObject = [result isEqualToString:@"object"];
        BOOL isEnable = !error && isObject;
        completion(isEnable);
    }];
}

@end
