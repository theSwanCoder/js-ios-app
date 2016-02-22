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
//  JMRestReportLoader.m
//  TIBCO JasperMobile
//

#import "JMRestReportLoader.h"
#import "NSObject+Additions.h"
#import "JMReportViewerVC.h"

@interface JSReportLoader (LoadHTML)
- (void)startLoadReportHTML;
@end

@interface JMRestReportLoader()

@end

@implementation JMRestReportLoader
@synthesize bridge = _bridge, delegate = _delegate;


#pragma mark - Custom accessors
- (void)setBridge:(JMJavascriptNativeBridge *)bridge
{
    _bridge = bridge;
//    _bridge.delegate = self;
}

#pragma mark - Public API
- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [self.bridge reset];
    [super refreshReportWithCompletion: completion];
}

- (void)destroy
{
    [self.bridge reset];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"changeInitialZoom(%@);";
    request.parametersAsString = @(scaleFactor).stringValue;
    [self.bridge sendJavascriptRequest:request
                            completion:nil];
}

#pragma mark - Private API
- (void)startLoadReportHTML
{
    NSString *jsMobilePath = [[NSBundle mainBundle] pathForResource:@"jaspermobile" ofType:@"js"];
    NSError *error;
    NSString *jsMobile = [NSString stringWithContentsOfFile:jsMobilePath encoding:NSUTF8StringEncoding error:&error];
    CGFloat initialZoom = 2;
    if ([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) {
        initialZoom = 1;
    }
    [self.bridge injectJSInitCode:jsMobile];
    [self.bridge startLoadHTMLString:self.report.HTMLString
                             baseURL:[NSURL URLWithString:self.report.baseURLString]
                          completion:nil];

    [self updateViewportScaleFactorWithValue:initialZoom];

    [super startLoadReportHTML];
}

@end
