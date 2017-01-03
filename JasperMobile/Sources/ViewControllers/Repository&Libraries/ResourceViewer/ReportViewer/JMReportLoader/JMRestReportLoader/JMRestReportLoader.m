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
#import "JMRESTWebEnvironment.h"
#import "JMHTMLParser.h"
#import "JMHTMLScript.h"
#import "JMJavascriptRequest.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"

typedef void(^JMRestReportLoaderCompletion)(BOOL, NSError *);

@interface JSReportLoader (LoadHTML)
- (void)startLoadReportHTML;
@end

@interface JMRestReportLoader()
@property (nonatomic, weak) JMRESTWebEnvironment *webEnvironment;
@end

@implementation JMRestReportLoader

#pragma mark - Initializers
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithRestClient:(JSRESTBase *)restClient
{
    self = [super initWithRestClient:restClient];
    return self;
}

+ (instancetype)loaderWithReport:(JSReport *)report
                      restClient:(JSRESTBase *)restClient
{
    return [[self alloc] initWithRestClient:restClient];
}


- (id <JMReportLoaderProtocol>)initWithRestClient:(JSRESTBase *)restClient
                                   webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [self initWithRestClient:restClient];
    if (self) {
        _webEnvironment = (JMRESTWebEnvironment *) webEnvironment;
    }
    return self;
}

+ (id<JMReportLoaderProtocol>)loaderWithRestClient:(nonnull JSRESTBase *)restClient
                                    webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithRestClient:restClient
                             webEnvironment:webEnvironment];
}

#pragma mark - JMReportLoaderProtocol

- (void)runReport:(JSReport *)report initialDestination:(JSReportDestination *)destination
initialParameters:(NSArray<JSReportParameter *> *)initialParameters
       completion:(JSReportLoaderCompletionBlock)completion
{
    [self runReport:report
        initialPage:@(destination.page)
  initialParameters:initialParameters
         completion:completion];
}

#pragma mark - Public API
- (void)refreshReportWithCompletion:(JMRestReportLoaderCompletion)completion
{
    [self destroy];
    [super refreshReportWithCompletion: completion];
}

- (void)fetchPage:(NSNumber *)page completion:(JSReportLoaderCompletionBlock)completion
{
    [super fetchPage:page completion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES, nil);
        } else {
            if ([error.domain isEqualToString:JSHTTPErrorDomain]) {
                NSDictionary *userInfo = error.userInfo;
                NSInteger httpCode = ((NSNumber *)userInfo[JSHTTPErrorResponseStatusKey]).integerValue;
                switch(httpCode) {
                    case 401: {
                        NSError *loaderError = [[NSError alloc] initWithDomain:@"JMReportLoader Error"
                                                                          code:JSReportLoaderErrorTypeSessionDidExpired
                                                                      userInfo:nil];
                        completion(NO, loaderError);
                        break;
                    }
                    default: {
                        completion(NO, error);
                    }
                }
            }
        }
    }];
}

- (void)destroy
{
    if (self.webEnvironment.state == JMWebEnvironmentStateEnvironmentReady) {
        if (self.webEnvironment.isReusable) {
            JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"API.injectContent"
                                                                                    inNamespace:JMJavascriptNamespaceRESTReport
                                                                                     parameters:@{
                                                                                             @"HTMLString" : @"",
                                                                                             @"transformationScale" : @"0.0"
                                                                                     }];
            [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                            completion:^(NSDictionary *params, NSError *error) {
                                                JMLog(@"params: %@", params);
                                                JMLog(@"error: %@", error);
                                                if (error) {
                                                    [self.webEnvironment clean];
                                                }
                                            }
                                      needSessionValid:NO];
        } else {
            [self.webEnvironment clean];
        }
    }
}

- (void)fitReportViewToScreen
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.fitReportViewToScreen"
                                                               inNamespace:JMJavascriptNamespaceRESTReport
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:nil];
}

- (void)resetWithCompletion:(nullable JSReportLoaderBaseCompletionBlock)completion
{
    [self destroy];
    if (completion) {
        completion();
    }
}

#pragma mark - Private API
- (void)startLoadReportHTML
{
    [self.webEnvironment loadHTML:self.report.HTMLString
                          baseURL:[NSURL URLWithString:self.report.baseURLString]
                       completion:^(BOOL isReady, NSError *error) {
                           JMJavascriptRequest *applyZoomRequest = [JMJavascriptRequest requestWithCommand:@"API.applyZoomForReport"
                                                                                               inNamespace:JMJavascriptNamespaceRESTReport
                                                                                                parameters:nil];
                           [self.webEnvironment sendJavascriptRequest:applyZoomRequest
                                                           completion:^(NSDictionary *params, NSError *error) {
                                                               if (error) {
                                                                   JMLog(@"error of applying zoom: %@", error);
                                                               }
                                                               [super startLoadReportHTML];
                                                           }
                                                     needSessionValid:NO];
                       }];
}

@end
