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
//  JMVisualizeReportLoader.h
//  TIBCO JasperMobile
//
#import "JMReportLoaderProtocol.h"
#import "JMReportViewerVC.h"
#import "JMVisualizeReportLoader.h"
#import "JMJavascriptNativeBridge.h"
#import "JMJavascriptRequest.h"
#import "JMVisualizeManager.h"
#import "JMJavascriptCallback.h"
#import "JMWebViewManager.h"

#import "JSReportParameter.h"
#import "JSRESTBase+JSRESTReport.h"



typedef NS_ENUM(NSInteger, JMReportViewerAlertViewType) {
    JMReportViewerAlertViewTypeEmptyReport,
    JMReportViewerAlertViewTypeErrorLoad
};

@interface JMVisualizeReportLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak, readwrite) JMReport *report;

@property (nonatomic, assign, readwrite) BOOL isReportInLoadingProcess;

@property (nonatomic, copy) void(^reportLoadCompletion)(BOOL success, NSError *error);
@property (nonatomic, copy) NSString *exportFormat;
@end

@implementation JMVisualizeReportLoader
@synthesize bridge = _bridge, delegate = _delegate;

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JMReport *)report restClient:(nonnull JSRESTBase *)restClient
{
    self = [super init];
    if (self) {
        _report = report;
        _visualizeManager = [JMVisualizeManager new];
    }
    return self;
}

+ (instancetype)loaderWithReport:(JMReport *)report restClient:(nonnull JSRESTBase *)restClient
{
    return [[self alloc] initWithReport:report restClient:restClient];
}

#pragma mark - Custom accessors
-(void)setReportLoadCompletion:(void (^)(BOOL, NSError *))reportLoadCompletion
{
    if (_reportLoadCompletion != reportLoadCompletion) {
        _reportLoadCompletion = [reportLoadCompletion copy];
    }
}

- (void)setBridge:(JMJavascriptNativeBridge *)bridge
{
    _bridge = bridge;
    _bridge.delegate = self;
}

#pragma mark - Public API
- (void)runReportWithPage:(NSInteger)page completion:(void(^)(BOOL success, NSError *error))completionBlock
{
    self.isReportInLoadingProcess = YES;
    self.report.isReportAlreadyLoaded = NO;
    [self.report updateCountOfPages:NSNotFound];
    [self.report updateCurrentPage:page];

    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        if (isWebViewLoaded) {
            [self fetchPageNumber:page withCompletion:completionBlock];
        } else {
            self.reportLoadCompletion = completionBlock;

            [self startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    [self.bridge startLoadHTMLString:self.report.HTMLString
                                             baseURL:[NSURL URLWithString:self.report.baseURLString]];
                } else {
                    NSLog(@"Error loading HTML%@", error.localizedDescription);
                }
            }];
        }
    }];
}

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(void(^)(BOOL success, NSError *error))completionBlock
{
    self.reportLoadCompletion = completionBlock;

    if (!self.report.isReportAlreadyLoaded) {
        NSString *parametersAsString = [self createParametersAsString];
        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"MobileReport.run(%@);";
        request.parametersAsString = [NSString stringWithFormat:@"{'uri': '%@', 'params': %@, 'pages' : '%@'}", self.report.reportURI, parametersAsString, @(pageNumber)];
        [self.bridge sendRequest:request];
    } else {
        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"MobileReport.selectPage(%@);";
        request.parametersAsString = @(pageNumber).stringValue;
        [self.bridge sendRequest:request];
    }
}

- (void)cancel
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileReport.cancel();";
    [self.bridge sendRequest:request];
}

- (void)applyReportParametersWithCompletion:(void(^)(BOOL success, NSError *error))completion
{

    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        if (isWebViewLoaded) {
            self.isReportInLoadingProcess = YES;
            self.report.isReportAlreadyLoaded = NO;

            self.reportLoadCompletion = completion;
            [self.report updateCurrentPage:1];

            [self startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                    if (success) {
                        [self.bridge startLoadHTMLString:self.report.HTMLString
                                                 baseURL:[NSURL URLWithString:self.report.baseURLString]];
                    } else {
                        NSLog(@"Error loading HTML%@", error.localizedDescription);
                    }
                }];
        } else if (!self.report.isReportAlreadyLoaded) {
            self.isReportInLoadingProcess = YES;
            self.report.isReportAlreadyLoaded = NO;
            [self.report updateCountOfPages:NSNotFound];

            [self fetchPageNumber:1 withCompletion:completion];
        } else {
            self.reportLoadCompletion = completion;
            [self.report updateCurrentPage:1];
            [self.report updateCountOfPages:NSNotFound];

            JMJavascriptRequest *request = [JMJavascriptRequest new];
            request.command = @"MobileReport.applyReportParams(%@);";
            request.parametersAsString = [self createParametersAsString];
            [self.bridge sendRequest:request];
        }
    }];
}

- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    self.reportLoadCompletion = completion;
    [self.report updateCurrentPage:1];
    [self.report updateCountOfPages:NSNotFound];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileReport.refresh(%@);";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)exportReportWithFormat:(NSString *)exportFormat
{
    self.exportFormat = exportFormat;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileReport.exportReport(%@);";
    request.parametersAsString = [NSString stringWithFormat:@"'%@'", exportFormat];
    [self.bridge sendRequest:request];
}

- (void)destroy
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileReport.destroyReport(%@);";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];

    self.report.isReportAlreadyLoaded = NO;
}

- (void)authenticate
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileReport.authorize(%@);";
    request.parametersAsString = [NSString stringWithFormat:@"{'username': '%@', 'password': '%@', 'organization': '%@'}", self.restClient.serverProfile.username, self.restClient.serverProfile.password, self.restClient.serverProfile.organization];
    [self.bridge sendRequest:request];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"JasperMobile.Helper.updateViewPortInitialScale(%@);";
        request.parametersAsString = [NSString stringWithFormat:@"%@", @(scaleFactor)];
        [self.bridge sendRequest:request];
    }
}

#pragma mark - Private
- (void)startLoadHTMLWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    JMLog(@"visuzalise.js did start load");
    [self.visualizeManager loadVisualizeJSWithCompletion:^(BOOL success, NSError *error){
        if (success) {
            JMLog(@"visuzalise.js did end load");
            NSString *baseURLString = self.restClient.serverProfile.serverUrl;
            [self.report updateHTMLString:[self.visualizeManager htmlStringForReport] baseURLSring:baseURLString];

            if (completion) {
                completion(YES, nil);
            }
        } else {
            // TODO: handle this error
            JMLog(@"Error loading visualize.js");
            // TODO: add error code
//            NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
//                                                 code:0
//                                             userInfo:nil];
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate
- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *)bridge didReceiveCallback:(JMJavascriptCallback *)callback
{
    if ([callback.type isEqualToString:@"DOMContentLoaded"]) {
        [self handleDOMContentLoaded];
    } else if ([callback.type isEqualToString:@"runReport"]) {
        [self handleRunReportWithParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"handleReferenceClick"]) {
        [self handleReferenceClickWithParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"reportDidObtaineMultipageState"]) {
        [self handleEventObtaineMultipageStateWithParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"reportRunDidCompleted"]) {
        [self handleEventReportRunDidCompletedWithParameters:callback.parameters];
    } else if([callback.type isEqualToString:@"reportDidEndRenderSuccessful"]) {
        [self handleReportEndRenderSuccessfull];
    } else if([callback.type isEqualToString:@"reportDidEndRenderFailured"]) {
        [self handleReportEndRenderFailedWithParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"exportPath"]) {
        [self handleExportParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"reportDidDidEndRefreshSuccessful"]) {
        [self handleRefreshDidEndSuccessful];
    } else if ([callback.type isEqualToString:@"reportDidEndRefreshFailured"]) {
        [self handleRefreshDidEndFailedWithParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"reportOnPageChange"]) {
        [self handleReportOnPageChangeWithParameters:callback.parameters];
    } else if ([callback.type isEqualToString:@"logging"]) {
        JMLog(@"visualize log: %@", callback.parameters[@"parameters"][@"message"]);
    } else if ([callback.type isEqualToString:@"onWindowError"]) {
        [self handleOnWinwowErrorWithMessage:callback.parameters[@"error"]];
    } else if ([callback.type isEqualToString:@"onPageLoadError"]) {
        [self handleOnPageLoadErrorWithParameters:callback.parameters];
    } else {
        JMLog(@"response parameters: %@", callback.parameters);
    }
}

- (void)javascriptNativeBridgeDidReceiveAuthRequest:(id <JMJavascriptNativeBridgeProtocol>)bridge
{
    // TODO: handle auth requests.
}

- (BOOL)javascriptNativeBridge:(id<JMJavascriptNativeBridgeProtocol>)bridge shouldLoadExternalRequest:(NSURLRequest *)request
{
    BOOL shouldLoad = NO;
    // TODO: verify all cases

    // Request for cleaning webview
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        shouldLoad = YES;
    }

    return shouldLoad;
}

#pragma mark - Helpers
- (NSString *)createParametersAsString
{
    NSMutableString *parametersAsString = [@"{" mutableCopy];
    for (JSReportParameter *parameter in self.report.reportParameters) {
        NSArray *values = parameter.value;
        NSString *stringValues = @"";
        for (NSString *value in values) {
            stringValues = [stringValues stringByAppendingFormat:@"\"%@\",", value];
        }
        [parametersAsString appendFormat:@"\"%@\":[%@],", parameter.name, stringValues];
    }
    [parametersAsString appendString:@"}"];
    return [parametersAsString copy];
}

- (NSError *)createErrorWithType:(JSReportLoaderErrorType)errorType errorMessage:(NSString *)errorMessage
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorMessage ?: JMCustomLocalizedString(@"report.viewer.visualize.render.error", nil) };
    NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                         code:errorType
                                     userInfo:userInfo];
    return error;
}

#pragma mark - DOM listeners
- (void)handleDOMContentLoaded
{
//    [self authenticate];
    [self fetchPageNumber:self.report.currentPage withCompletion:self.reportLoadCompletion];
}

#pragma mark - Run report
- (void)handleReportEndRenderSuccessfull
{
    JMLog(@"report rendering end");

    self.report.isReportAlreadyLoaded = YES;

    if (self.reportLoadCompletion) {
        self.reportLoadCompletion(YES, nil);
    }
}

- (void)handleReportEndRenderFailedWithParameters:(NSDictionary *)parameters
{
    if (self.reportLoadCompletion) {
        NSString *errorCode = parameters[@"parameters"][@"code"];
        NSString *message = parameters[@"parameters"][@"message"];
        JSReportLoaderErrorType code = JSReportLoaderErrorTypeUndefined;
        if ([errorCode isEqualToString:@"authentication.error"]) {
            code = JSReportLoaderErrorTypeAuthentification;
        }

        NSError *error = [self createErrorWithType:code
                                      errorMessage:message];

        self.reportLoadCompletion(NO, error);
    }
}

- (void)handleEventReportRunDidCompletedWithParameters:(NSDictionary *)parameters
{
    NSInteger countOfPages = 0;
    if (parameters[@"parameters"]) {
        countOfPages = ((NSNumber *)parameters[@"parameters"][@"pages"]).integerValue;
    } else {
        countOfPages = ((NSNumber *)parameters[@"pages"]).integerValue;
    }
    [self.report updateCountOfPages:countOfPages];
    self.report.isReportAlreadyLoaded = YES;

    if (self.reportLoadCompletion) {
        self.reportLoadCompletion(YES, nil);
        self.reportLoadCompletion = nil;
    }
}

- (void)handleReportOnPageChangeWithParameters:(NSDictionary *)parameters
{
    NSInteger currentPage = 0;
    if (parameters[@"parameters"]) {
        currentPage = ((NSNumber *)parameters[@"parameters"][@"page"]).integerValue;
    } else {
        currentPage = ((NSNumber *)parameters[@"page"]).integerValue;
    }
    [self.report updateCurrentPage:currentPage];
}

#pragma mark - Multipage
- (void)handleEventObtaineMultipageStateWithParameters:(NSDictionary *)parameters
{
    BOOL isMultiPage =((NSNumber *)parameters[@"isMultiPage"]).boolValue;
    [self.report updateIsMultiPageReport:isMultiPage];
}

#pragma mark - Handle refresh
- (void)handleRefreshDidEndSuccessful
{
    self.report.isReportAlreadyLoaded = YES;

    if (self.reportLoadCompletion) {
        self.reportLoadCompletion(YES, nil);
    }
}

- (void)handleRefreshDidEndFailedWithParameters:(NSDictionary *)parameters
{
    if (self.reportLoadCompletion) {
        // TODO: add error
        self.reportLoadCompletion(NO, nil);
    }
}

#pragma mark - Export report
- (void)handleExportParameters:(NSDictionary *)parameters
{
    NSString *outputResourcesPath = @"";
    if (parameters[@"parameters"]) {
        outputResourcesPath = parameters[@"parameters"][@"link"];
    } else {
        outputResourcesPath = parameters[@"link"];
    }
    if (outputResourcesPath) {
        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOutputResourcePath:fullReportName:)]) {
            NSString *fullReportName = [NSString stringWithFormat:@"%@.%@", self.report.resourceLookup.label, self.exportFormat];
            [self.delegate reportLoader:self didReceiveOutputResourcePath:outputResourcesPath fullReportName:fullReportName];
        }
    }
}

#pragma mark - Hyperlinks handlers
- (void)handleReferenceClickWithParameters:(NSDictionary *)parameters
{
    NSString *locationString = parameters[@"location"];
    if (locationString) {
        NSURL *locationURL = [NSURL URLWithString:locationString];
        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForReference:)]) {
            [self.delegate reportLoader:self didReceiveOnClickEventForReference:locationURL];
        }
    }
}

- (void)handleRunReportWithParameters:(NSDictionary *)parameters
{
    NSDictionary *json;
    NSError *jsonError;
    if (parameters[@"parameters"]) {
        json = parameters[@"parameters"][@"data"];
    } else {
        NSString *params = parameters[@"data"];
        if (!params) {
            return;
        }
        NSData *jsonData = [params dataUsingEncoding:NSUTF8StringEncoding];
        json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    }

    NSString *reportPath;
    if (json) {
        reportPath = json[@"resource"];

        if (reportPath) {
            [self.restClient resourceLookupForURI:reportPath resourceType:kJS_WS_TYPE_REPORT_UNIT modelClass:[JSResourceLookup class] completionBlock:^(JSOperationResult *result) {
                NSError *error = result.error;
                if (error) {
                    NSString *errorString = error.localizedDescription;
                    JSReportLoaderErrorType errorType = JSReportLoaderErrorTypeUndefined;
                    if (errorString && [errorString rangeOfString:@"unauthorized"].length) {
                        errorType = JSReportLoaderErrorTypeAuthentification;
                    }
                    if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventWithError:)]) {
                        [self.delegate reportLoader:self didReceiveOnClickEventWithError:[self createErrorWithType:errorType errorMessage:errorString]];
                    }
                } else {
                    JSResourceLookup *resourceLookup = [result.objects firstObject];
                    if (resourceLookup) {
                        resourceLookup.resourceType = kJS_WS_TYPE_REPORT_UNIT;

                        NSMutableArray *reportParameters = [NSMutableArray array];
                        NSDictionary *rawParameters = json[@"params"];
                        for (NSString *key in rawParameters) {
                            JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:key
                                                                                                   value:rawParameters[key]];
                            [reportParameters addObject:reportParameter];
                        }

                        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForResourceLookup:withParameters:)]) {
                            [self.delegate reportLoader:self didReceiveOnClickEventForResourceLookup:resourceLookup withParameters:[reportParameters copy]];
                        }
                    }
                }
            }];
        }

    } else {
        JMLog(@"parse json with error: %@", jsonError.localizedDescription);
    }
}

#pragma mark - Error handlers
- (void)handleOnWinwowErrorWithMessage:(NSString *)message
{
    if (self.reportLoadCompletion) {
        self.reportLoadCompletion(NO, [self createErrorWithType:JSReportLoaderErrorTypeUndefined
                                                   errorMessage:message]);
        self.reportLoadCompletion = nil;
    }
}

- (void)handleOnPageLoadErrorWithParameters:(NSDictionary *)parameters
{
    NSDictionary *params = parameters[@"parameters"];
    NSString *errorCode = params[@"message"][@"errorCode"];
    NSString *message = params[@"message"][@"message"];

    if ([errorCode isEqualToString:@"authentication.error"]) {
        if (self.reportLoadCompletion) {
            self.reportLoadCompletion(NO, [self createErrorWithType:JSReportLoaderErrorTypeAuthentification
                                                       errorMessage:message]);
            self.reportLoadCompletion = nil;
        }
    }
}

@end
