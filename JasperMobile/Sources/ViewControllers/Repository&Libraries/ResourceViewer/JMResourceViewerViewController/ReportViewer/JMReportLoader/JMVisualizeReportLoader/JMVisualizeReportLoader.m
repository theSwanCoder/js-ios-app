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
    self.isReportInLoadingProcess = YES;
    self.report.isReportAlreadyLoaded = NO;
    [self.report updateCountOfPages:NSNotFound];
    [self.report updateCurrentPage:page];

    [self addListenersForVisualizeEvents];

    JSReportLoaderCompletionBlock heapBlock = [completionBlock copy];
    __weak __typeof(self) weakSelf = self;
    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        __typeof(self) strongSelf = weakSelf;
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
                                              if (error) {
                                                  JMLog(@"error: %@", error);
                                              } else {
                                                  [strongSelf fetchPageNumber:strongSelf.report.currentPage
                                                               withCompletion:heapBlock];
                                              }
                                          }];
                } else {
                    NSLog(@"Error loading HTML%@", error.localizedDescription);
                }
            }];
        }
    }];
}

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(JSReportLoaderCompletionBlock)completionBlock
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    JSReportLoaderCompletionBlock heapBlock = [completionBlock copy];
    JMJavascriptRequestCompletion jsRequestCompletion;
    if (!self.report.isReportAlreadyLoaded) {
        request.command = @"JasperMobile.Report.API.run";
        NSString *parametersAsString = [self createParametersAsString];
        request.parametersAsString = [NSString stringWithFormat:@"{'uri': '%@', 'params': %@, 'pages' : '%@'}", self.report.reportURI, parametersAsString, @(pageNumber)];
        __weak __typeof(self) weakSelf = self;
        jsRequestCompletion = ^(JMJavascriptCallback *callback, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                heapBlock(NO, error);
            } else {
                JMLog(@"running report was finished");
                strongSelf.report.isReportAlreadyLoaded = YES;
                if (heapBlock) {
                    heapBlock(YES, nil);
                }
            }
        };
    } else {
        request.command = @"JasperMobile.Report.API.selectPage";
        request.parametersAsString = @(pageNumber).stringValue;
        jsRequestCompletion = ^(JMJavascriptCallback *callback, NSError *error) {
            if (error) {
                heapBlock(NO, error);
            } else {
                JMLog(@"selecting page was finished");
                if (heapBlock) {
                    heapBlock(YES, nil);
                }
            }
        };
    }
    [self.bridge sendJavascriptRequest:request
                            completion:jsRequestCompletion];
}

- (void)cancel
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.cancel";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"canceling report was finished");
        }
    }];
}

- (void)applyReportParametersWithCompletion:(JSReportLoaderCompletionBlock)completion
{
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    __weak __typeof(self) weakSelf = self;
    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        __typeof(self) strongSelf = weakSelf;
        if (isWebViewLoaded) {
            strongSelf.isReportInLoadingProcess = YES;
            strongSelf.report.isReportAlreadyLoaded = NO;

            [strongSelf.report updateCurrentPage:1];

            [strongSelf startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                    if (success) {
                        __weak __typeof(self) weakSelf = strongSelf;
                        [strongSelf.bridge startLoadHTMLString:strongSelf.report.HTMLString
                                                       baseURL:[NSURL URLWithString:strongSelf.report.baseURLString]
                                                    completion:^(JMJavascriptCallback *callback, NSError *error) {
                                                        __typeof(self) strongSelf = weakSelf;
                                                        if (error) {
                                                            if (heapBlock) {
                                                                heapBlock(NO, error);
                                                            }
                                                        } else {
                                                            [strongSelf fetchPageNumber:strongSelf.report.currentPage
                                                                         withCompletion:heapBlock];
                                                        }
                                                    }];
                    } else {
                        if (heapBlock) {
                            heapBlock(NO, error);
                        }
                    }
                }];
        } else if (!strongSelf.report.isReportAlreadyLoaded) {
            strongSelf.isReportInLoadingProcess = YES;
            strongSelf.report.isReportAlreadyLoaded = NO;
            [strongSelf.report updateCountOfPages:NSNotFound];

            [strongSelf fetchPageNumber:1
                         withCompletion:heapBlock];
        } else {
            [strongSelf.report updateCurrentPage:1];
            [strongSelf.report updateCountOfPages:NSNotFound];

            JMJavascriptRequest *request = [JMJavascriptRequest new];
            request.command = @"JasperMobile.Report.API.applyReportParams";
            request.parametersAsString = [strongSelf createParametersAsString];
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (error) {
                    JMLog(@"error: %@", error);
                } else {
                    JMLog(@"applying parameters was finished");
                    strongSelf.report.isReportAlreadyLoaded = YES;
                    if (heapBlock) {
                        heapBlock(YES, nil);
                    }
                }
            }];
        }
    }];
}

- (void)refreshReportWithCompletion:(JSReportLoaderCompletionBlock)completion
{
    [self.report updateCurrentPage:1];
    [self.report updateCountOfPages:NSNotFound];

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.refresh";
    request.parametersAsString = @"";
    __weak __typeof(self) weakSelf = self;
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            if (heapBlock) {
                heapBlock(NO, error);
            }
        } else {
            JMLog(@"refreshing report was finished");
            strongSelf.report.isReportAlreadyLoaded = YES;
            if (heapBlock) {
                heapBlock(YES, nil);
            }
        }
    }];
}

- (void)exportReportWithFormat:(NSString *)exportFormat
{
    self.exportFormat = exportFormat;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.exportReport";
    request.parametersAsString = [NSString stringWithFormat:@"'%@'", exportFormat];
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"getting output resource link was finished");
            NSString *outputResourcesPath = callback.parameters[@"link"];
            if (outputResourcesPath) {
                if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOutputResourcePath:fullReportName:)]) {
                    NSString *fullReportName = [NSString stringWithFormat:@"%@.%@", self.report.resourceLookup.label, self.exportFormat];
                    [self.delegate reportLoader:self didReceiveOutputResourcePath:outputResourcesPath fullReportName:fullReportName];
                }
            }
        }
    }];
}

- (void)destroy
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.API.destroyReport";
    request.parametersAsString = @"";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
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

@end
