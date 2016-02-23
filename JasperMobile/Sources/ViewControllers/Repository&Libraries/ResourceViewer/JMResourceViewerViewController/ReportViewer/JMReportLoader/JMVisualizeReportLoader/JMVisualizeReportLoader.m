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
#import "JMVisualizeManager.h"
#import "JMWebViewManager.h"

@interface JMVisualizeReportLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak, readwrite) JMReport *report;
@property (nonatomic, assign, readwrite) BOOL isReportInLoadingProcess;
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

- (void)setBridge:(JMJavascriptNativeBridge *)bridge
{
    _bridge = bridge;
    _bridge.delegate = self;
}

#pragma mark - Public API
- (void)runReportWithPage:(NSInteger)page completion:(JSReportLoaderCompletionBlock)completionBlock
{
    [self addListenersForVisualizeEvents];

    JSReportLoaderCompletionBlock heapBlock = [completionBlock copy];
    __weak __typeof(self) weakSelf = self;
    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        __typeof(self) strongSelf = weakSelf;
        strongSelf.isReportInLoadingProcess = YES;
        if (isWebViewLoaded) {
            [strongSelf fetchPageNumber:page
                         withCompletion:heapBlock];
        } else {
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (success) {
                    __weak __typeof(self) weakSelf = strongSelf;
                    [strongSelf.bridge startLoadHTMLString:strongSelf.report.HTMLString
                                             baseURL:[NSURL URLWithString:strongSelf.report.baseURLString]
                                          completion:^(JMJavascriptCallback *callback, NSError *error) {
                                              __typeof(self) strongSelf = weakSelf;
                                              if (callback) {
                                                  [strongSelf freshLoadReportWithPageNumber:page
                                                                           completion:completionBlock];
                                              } else {
                                                  if (heapBlock) {
                                                      NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                                      heapBlock(NO, vizError);
                                                  }
                                              }
                                          }];
                } else {
                    if (heapBlock) {
                        heapBlock(NO, error);
                    }
                }
            }];
        }
    }];
}

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(JSReportLoaderCompletionBlock)completionBlock
{
    if (!self.report.isReportAlreadyLoaded) {
        [self freshLoadReportWithPageNumber:pageNumber
                                 completion:completionBlock];
    } else {
        [self selectPageWithPageNumber:pageNumber
                            completion:completionBlock];
    }
}

- (void)cancel
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.cancel";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (callback) {
            JMLog(@"canceling report was finished");
        } else {
            JMLog(@"error: %@", error);
        }
    }];
}

- (void)applyReportParametersWithCompletion:(JSReportLoaderCompletionBlock)completion
{
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    __weak __typeof(self) weakSelf = self;
    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        __typeof(self) strongSelf = weakSelf;
        if (!isWebViewLoaded) {
            strongSelf.isReportInLoadingProcess = YES;
            [strongSelf startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                    if (success) {
                        __weak __typeof(self) weakSelf = strongSelf;
                        [strongSelf.bridge startLoadHTMLString:strongSelf.report.HTMLString
                                                       baseURL:[NSURL URLWithString:strongSelf.report.baseURLString]
                                                    completion:^(JMJavascriptCallback *callback, NSError *error) {
                                                        __typeof(self) strongSelf = weakSelf;
                                                        if (callback) {
                                                            [strongSelf freshLoadReportWithPageNumber:strongSelf.report.currentPage
                                                                                           completion:completion];
                                                        } else {
                                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                                            heapBlock(NO, vizError);
                                                        }
                                                    }];
                    } else {
                        if (heapBlock) {
                            heapBlock(NO, error);
                        }
                    }
                }];
        } else {
            [strongSelf.report updateCurrentPage:1];
            [strongSelf.report updateCountOfPages:NSNotFound];

            JMJavascriptRequest *request = [JMJavascriptRequest new];
            request.command = @"JasperMobile.Report.API.applyReportParams";
            request.parametersAsString = [strongSelf createParametersAsString];
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (callback) {
                    if (heapBlock) {
                        heapBlock(YES, nil);
                    }
                } else {
                    if (heapBlock) {
                        NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                        heapBlock(NO, vizError);
                    }
                }
            }];
        }
    }];
}

- (void)refreshReportWithCompletion:(JSReportLoaderCompletionBlock)completion
{
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    // need for clean running, but not selecting page
    self.report.isReportAlreadyLoaded = NO;
    [self.report updateCountOfPages:NSNotFound];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.refresh";

    __weak __typeof(self) weakSelf = self;
    [self.bridge sendJavascriptRequest:request
                            completion:^(JMJavascriptCallback *callback, NSError *error) {
                                __typeof(self) strongSelf = weakSelf;
                                if (callback) {
                                    strongSelf.report.isReportAlreadyLoaded = YES;
                                    if (heapBlock) {
                                        heapBlock(YES, nil);
                                    }
                                } else {
                                    if (heapBlock) {
                                        NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                        heapBlock(NO, vizError);
                                    }
                                }
                            }];
}

- (void)exportReportWithFormat:(NSString *)exportFormat
{
    // TODO: make refactor - use completion
    self.exportFormat = exportFormat;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.exportReport";
    request.parametersAsString = [NSString stringWithFormat:@"'%@'", exportFormat];
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (callback) {
            JMLog(@"getting output resource link was finished");
            NSString *outputResourcesPath = callback.parameters[@"link"];
            if (outputResourcesPath) {
                if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOutputResourcePath:fullReportName:)]) {
                    NSString *fullReportName = [NSString stringWithFormat:@"%@.%@", self.report.resourceLookup.label, self.exportFormat];
                    [self.delegate reportLoader:self didReceiveOutputResourcePath:outputResourcesPath fullReportName:fullReportName];
                }
            }
        } else {
            JMLog(@"error: %@", error);
        }
    }];
}

- (void)destroy
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.destroyReport";
    request.parametersAsString = @"";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (callback) {
            JMLog(@"callback: %@", callback);
        } else {
            JMLog(@"error: %@", error);
        }
    }];

    self.report.isReportAlreadyLoaded = NO;
    [self.bridge removeAllListeners];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"JasperMobile.Helper.updateViewPortInitialScale";
        request.parametersAsString = [NSString stringWithFormat:@"%@", @(scaleFactor)];
        [self.bridge sendJavascriptRequest:request
                                completion:nil];
    }
}

#pragma mark - Private
- (void)freshLoadReportWithPageNumber:(NSInteger)pageNumber completion:(JSReportLoaderCompletionBlock)completion
{
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    // need for clean running, but not selecting page
    self.report.isReportAlreadyLoaded = NO;
    [self.report updateCountOfPages:NSNotFound];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.runReport";
    request.parametersAsString = [self makeParametersForRunReportRequestWithPageNumber:pageNumber];

    __weak __typeof(self) weakSelf = self;
    [self.bridge sendJavascriptRequest:request
                            completion:^(JMJavascriptCallback *callback, NSError *error) {
                                __typeof(self) strongSelf = weakSelf;
                                if (callback) {
                                    strongSelf.report.isReportAlreadyLoaded = YES;
                                    strongSelf.isReportInLoadingProcess = NO;
                                    [strongSelf.report updateCurrentPage:pageNumber];
                                    if (heapBlock) {
                                        heapBlock(YES, nil);
                                    }
                                } else {
                                    if (heapBlock) {
                                        NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                        heapBlock(NO, vizError);
                                    }
                                }
                            }];
}

- (void)selectPageWithPageNumber:(NSInteger)pageNumber completion:(JSReportLoaderCompletionBlock)completion
{
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.selectPage";
    request.parametersAsString = @(pageNumber).stringValue;

    __weak __typeof(self) weakSelf = self;
    [self.bridge sendJavascriptRequest:request
                            completion:^(JMJavascriptCallback *callback, NSError *error) {
                                __typeof(self) strongSelf = weakSelf;
                                if (callback) {
                                    [strongSelf.report updateCurrentPage:pageNumber];
                                    if (heapBlock) {
                                        heapBlock(YES, nil);
                                    }
                                } else {
                                    if (heapBlock) {
                                        NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                        heapBlock(NO, vizError);
                                    }
                                }
                            }];
}

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
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

- (void)addListenersForVisualizeEvents
{
    NSString *reportCompletedListenerId = @"JasperMobile.Report.API.run.reportCompleted";
    __weak __typeof(self) weakSelf = self;
    [self.bridge addListenerWithId:reportCompletedListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.reportCompleted");
        __typeof(self) strongSelf = weakSelf;
        // TODO: move into separate method
        NSInteger countOfPages = ((NSNumber *)callback.parameters[@"pages"]).integerValue;
        [strongSelf.report updateCountOfPages:countOfPages];
    }];
    NSString *changePagesStateListenerId = @"JasperMobile.Report.API.run.changePagesState";
    [self.bridge addListenerWithId:changePagesStateListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.changePagesState");
    }];
    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.Report.API.run.linkOptions.events.ReportExecution";
    [self.bridge addListenerWithId:reportExecutionLinkOptionListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.ReportExecution");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleRunReportWithParameters:callback.parameters];
    }];
    NSString *localPageLinkOptionListenerId = @"JasperMobile.Report.API.run.linkOptions.events.LocalPage";
    [self.bridge addListenerWithId:localPageLinkOptionListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.LocalPage");
    }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.Report.API.run.linkOptions.events.Reference";
    [self.bridge addListenerWithId:referenceLinkOptionListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.Reference");
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = callback.parameters[@"location"];
        if (locationString) {
            NSURL *locationURL = [NSURL URLWithString:locationString];
            if ([strongSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForReference:)]) {
                [strongSelf.delegate reportLoader:strongSelf didReceiveOnClickEventForReference:locationURL];
            }
        }
    }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate

- (void)javascriptNativeBridgeDidReceiveAuthRequest:(JMJavascriptNativeBridge *)bridge
{
    // TODO: handle auth requests.
}

- (BOOL)javascriptNativeBridge:(JMJavascriptNativeBridge *)bridge shouldLoadExternalRequest:(NSURLRequest *)request
{
    BOOL shouldLoad = NO;
    // TODO: verify all cases

    // Request for cleaning webview
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        shouldLoad = YES;
    }

    return shouldLoad;
}

- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge didReceiveOnWindowError:(NSError *__nonnull)error
{
    // TODO: add handle this error
//    [self.bridge reset];
    JMLog(@"error: %@", error);
}

#pragma mark - Helpers
- (NSString *)makeParametersForRunReportRequestWithPageNumber:(NSInteger)pageNumber
{
    NSString *parametersAsString = [self createParametersAsString];
    NSString *uriParam = [NSString stringWithFormat:@"'uri' : '%@'", self.report.reportURI];
    NSString *reportParams = [NSString stringWithFormat:@"'params' : %@", parametersAsString];
    NSString *pagesParam = [NSString stringWithFormat:@"'pages' : '%@'", @(pageNumber)];

    NSString *requestParameters;

    BOOL isServerAmber = [JMUtils isServerAmber];
    NSString *isServerAmberParam;
    if (isServerAmber) {
        isServerAmberParam = @"'is_for_6_0' : true";
    } else {
        isServerAmberParam = @"'is_for_6_0' : false";
    }
    requestParameters = [NSString stringWithFormat:@"{%@, %@, %@, %@}",
                                                   isServerAmberParam,
                                                   uriParam,
                                                   reportParams,
                                                   pagesParam];

    return requestParameters;
}

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

#pragma mark - Hyperlinks handlers
- (void)handleRunReportWithParameters:(NSDictionary *)parameters
{
    NSDictionary *params = parameters[@"data"];
    if (!params) {
        return;
    }

    NSString *reportPath = params[@"resource"];;
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
                    NSDictionary *rawParameters = params[@"params"];
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
}

- (NSError *)createErrorWithType:(JSReportLoaderErrorType)errorType errorMessage:(NSString *)errorMessage
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorMessage ?: JMCustomLocalizedString(@"report.viewer.visualize.render.error", nil) };
    NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                         code:errorType
                                     userInfo:userInfo];
    return error;
}

#pragma mark - Errors handling
- (NSError *)loaderErrorFromBridgeError:(NSError *)error
{
    JSReportLoaderErrorType errorCode = JSReportLoaderErrorTypeUndefined;
    switch(error.code) {
        case JMJavascriptNativeBridgeErrorAuthError: {
            errorCode = JSReportLoaderErrorTypeAuthentification;
            break;
        }
        case JMJavascriptNativeBridgeErrorTypeOther: {
            errorCode = JSReportLoaderErrorTypeUndefined;
            break;
        }
        case JMJavascriptNativeBridgeErrorTypeWindow: {
            errorCode = JSReportLoaderErrorTypeUndefined;
            break;
        }
        default:
            break;
    }
    NSError *loaderError = [NSError errorWithDomain:error.domain
                                               code:errorCode
                                           userInfo:error.userInfo];
    return loaderError;
}

@end
