/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMWebEnvironment.h"
#import "JMUtils.h"
#import "JMReportChartType.h"
#import "JMWebEnvironmentUpdateCookiesTask.h"

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

// USE FOR TESTS ONLY
- (void)updateCookiesInWebView:(NSArray <NSHTTPCookie *>*)cookies
{
    JMWebEnvironmentUpdateCookiesTask *task = [JMWebEnvironmentUpdateCookiesTask taskWithRESTClient:self.restClient
                                                                                    requestExecutor:self.requestExecutor
                                                                                            cookies:cookies
                                                                                          competion:nil];
    [task start];
}

@end
