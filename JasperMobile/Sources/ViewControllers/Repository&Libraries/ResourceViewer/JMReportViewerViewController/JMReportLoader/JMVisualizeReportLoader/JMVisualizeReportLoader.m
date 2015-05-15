/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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

#import "JMBaseReportViewerViewController.h"
#import "JMVisualizeReportViewerViewController.h"
#import "JMVisualizeReportLoader.h"
#import "JMVisualizeReport.h"
#import "JMUtils.h"

typedef NS_ENUM(NSInteger, JMReportViewerAlertViewType) {
    JMReportViewerAlertViewTypeEmptyReport,
    JMReportViewerAlertViewTypeErrorLoad
};

@interface JMVisualizeReportLoader()
@property (nonatomic, weak) JMVisualizeReport *report;
@property (nonatomic, assign, readwrite) BOOL isReportInLoadingProcess;

@property (nonatomic, strong) NSString *visualizePath;
@property (nonatomic, copy) void(^reportLoadCompletion)(BOOL success, NSError *error);
@property (nonatomic, copy) NSString *exportFormat;
@end

@implementation JMVisualizeReportLoader

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JMVisualizeReport *)report
{
    self = [super init];
    if (self) {
        _report = report;
    }
    return self;
}

+ (instancetype)loaderWithReport:(JMVisualizeReport *)report
{
    return [[self alloc] initWithReport:report];
}

#pragma mark - Custom accessors
- (NSString *)visualizePath
{
    if (!_visualizePath) {
        NSString *visualizePath = [NSString stringWithFormat:@"%@/client/visualize.js", self.restClient.serverProfile.serverUrl];

        if ([JMUtils isServerVersionUpOrEqual6] && ![JMUtils isServerAmber2]) {
            visualizePath = [visualizePath stringByAppendingString:@"?_opt=false"];
        }
        _visualizePath = visualizePath;
    }
    return _visualizePath;
}

-(void)setReportLoadCompletion:(void (^)(BOOL, NSError *))reportLoadCompletion
{
    if (_reportLoadCompletion != reportLoadCompletion) {
        _reportLoadCompletion = [reportLoadCompletion copy];
    }
}

#pragma mark - Public API
- (void)runReportWithPage:(NSInteger)page completion:(void(^)(BOOL success, NSError *error))completionBlock
{
    self.isReportInLoadingProcess = YES;
    [self.report updateLoadingStatusWithValue:NO];
    [self.report updateCountOfPages:NSNotFound];

    if (![JMVisualizeWebViewManager sharedInstance].isVisualizeLoaded) {
        self.reportLoadCompletion = completionBlock;
        [self.report updateCurrentPage:page];
        [self.report updateCountOfPages:NSNotFound];

        [self startLoadHTMLWithCompletion:@weakself(^(BOOL success, NSError *error)) {
            if (success) {
                [JMVisualizeWebViewManager sharedInstance].isVisualizeLoaded = YES;
                [self.webView stopLoading];
                [self.webView loadHTMLString:self.report.HTMLString
                                     baseURL:[NSURL URLWithString:self.report.baseURLString]];
            } else {
                NSLog(@"Error loading HTML%@", error.localizedDescription);
            }
        }@weakselfend];
    } else {
        [self fetchPageNumber:page withCompletion:completionBlock];
    }
}

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(void(^)(BOOL success, NSError *error))completionBlock
{
    self.reportLoadCompletion = completionBlock;
    [self.report updateCurrentPage:pageNumber];

    if (!self.report.isReportAlreadyLoaded) {
        NSString *parametersAsString = [self createParametersAsString];
        NSString *runReportCommand = [NSString stringWithFormat:@"MobileReport.run({'uri': '%@', 'params': %@, 'pages' : '%@'});", self.report.reportURI, parametersAsString, @(pageNumber)];
        [self.webView stringByEvaluatingJavaScriptFromString:runReportCommand];
    } else {
        NSString *setPageCommand = [NSString stringWithFormat:@"MobileReport.selectPage(%@)", @(pageNumber).stringValue];
        [self.webView stringByEvaluatingJavaScriptFromString:setPageCommand];
    }
}

- (void) cancelReport
{
    // TODO: need cancel?
}

- (void)applyReportParametersWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    if (![JMVisualizeWebViewManager sharedInstance].isVisualizeLoaded) {
        self.isReportInLoadingProcess = YES;
        [self.report updateLoadingStatusWithValue:NO];

        self.reportLoadCompletion = completion;
        [self.report updateCurrentPage:1];

        [self startLoadHTMLWithCompletion:@weakself(^(BOOL success, NSError *error)) {
                if (success) {
                    [JMVisualizeWebViewManager sharedInstance].isVisualizeLoaded = YES;
                    [self.webView stopLoading];
                    [self.webView loadHTMLString:self.report.HTMLString
                                         baseURL:[NSURL URLWithString:self.report.baseURLString]];
                } else {
                    NSLog(@"Error loading HTML%@", error.localizedDescription);
                }
            }@weakselfend];
    } else if (!self.report.isReportAlreadyLoaded) {
        self.isReportInLoadingProcess = YES;
        [self.report updateLoadingStatusWithValue:NO];
        [self.report updateCountOfPages:NSNotFound];

        [self fetchPageNumber:1 withCompletion:completion];
    } else {
        self.reportLoadCompletion = completion;
        [self.report updateCurrentPage:1];
        [self.report updateCountOfPages:NSNotFound];

        NSString *parametersAsString = [self createParametersAsString];
        NSString *refreshReportCommand = [NSString stringWithFormat:@"MobileReport.applyReportParams(%@);", parametersAsString];
        [self.webView stringByEvaluatingJavaScriptFromString:refreshReportCommand];
    }
}

- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
//    [self.report updateLoadingStatusWithValue:NO];
//    [self fetchPageNumber:1 withCompletion:completion];
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // TODO: need understand logic of refresh via visualize.js
    self.reportLoadCompletion = completion;
    [self.report updateCurrentPage:1];
    [self.report updateCountOfPages:NSNotFound];

    NSString *refreshReportCommand = [NSString stringWithFormat:@"MobileReport.refresh();"];
    [self.webView stringByEvaluatingJavaScriptFromString:refreshReportCommand];
}

- (void)exportReportWithFormat:(NSString *)exportFormat
{
    self.exportFormat = exportFormat;
    NSString *exportReportCommand = [NSString stringWithFormat:@"MobileReport.exportReport('%@');", exportFormat];
    [self.webView stringByEvaluatingJavaScriptFromString:exportReportCommand];
}

- (void)destroyReport
{
    NSString *runReportCommand = [NSString stringWithFormat:@"MobileReport.destroy();"];
    [self.webView stringByEvaluatingJavaScriptFromString:runReportCommand];
    [self.report updateLoadingStatusWithValue:NO];
}

#pragma mark - Private
- (void)startLoadHTMLWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    NSLog(@"visuzalise.js did start load");
    [self loadVisualizeJSWithCompletion:@weakself(^(BOOL success, NSError *error)){
        if (success) {
            NSLog(@"visuzalise.js did end load");
            NSString *baseURLString = self.restClient.serverProfile.serverUrl;
            [self.report updateHTMLString:[self htmlString] baseURLSring:baseURLString];
            if (completion) {
                completion(YES, nil);
            }
        } else {
            // TODO: handle this error
            NSLog(@"Error loading visualize.js");
            // TODO: add error code
            NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                                 code:0
                                             userInfo:nil];
            if (completion) {
                completion(NO, error);
            }
        }
    }@weakselfend];
}

#pragma mark - Helpers
- (NSString *)htmlString
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"report_optimized" ofType:@"html"];
    if ([JMUtils isServerVersionUpOrEqual6] && ![JMUtils isServerAmber2]) {
        htmlPath = [[NSBundle mainBundle] pathForResource:@"report" ofType:@"html"];
    }

    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    // Visualize
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"VISUALIZE_PATH" withString:self.visualizePath];

    // REQUIRE_JS
    NSString *requireJSPath = [[NSBundle mainBundle] pathForResource:@"require.min" ofType:@"js"];
    NSString *requirejsString = [NSString stringWithContentsOfFile:requireJSPath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"REQUIRE_JS" withString:requirejsString];

    // JasperMobile
    NSString *jaspermobilePath = [[NSBundle mainBundle] pathForResource:@"report-ios-mobilejs-sdk" ofType:@"js"];
    NSString *jaspermobileString = [NSString stringWithContentsOfFile:jaspermobilePath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"JASPERMOBILE_SCRIPT" withString:jaspermobileString];

    return htmlString;
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

- (NSError *)createErrorWithType:(JMReportLoaderErrorType)errorType errorMessage:(NSString *)errorMessage
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorMessage ?: JMCustomLocalizedString(@"report.viewer.visualize.render.error", nil) };
    NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                         code:errorType
                                     userInfo:userInfo];
    return error;
}

#pragma mark - Load Visualize.js
- (void)loadVisualizeJSWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    if ([self isVisualizeLoaded]) {
        if (completion) {
            completion(YES, nil);
        }
        return;
    }

    NSURLResponse *response;
    NSError *error;

    NSURLRequest *visualizeJSRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.visualizePath]];
    NSData *data = [NSURLConnection sendSynchronousRequest:visualizeJSRequest returningResponse:&response error:&error];
    if (data) {
        // cache visualize.js
        NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:visualizeJSRequest];

        if (completion) {
            completion(YES, nil);
        }
    } else {
        if (completion) {
            completion(NO, error);
        }
    }
}

- (BOOL)isVisualizeLoaded
{
    BOOL isVisualizeLoaded = NO;
    NSURLRequest *visualizeJSRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.visualizePath]];
    if ([[NSURLCache sharedURLCache] cachedResponseForRequest:visualizeJSRequest]) {
        isVisualizeLoaded = YES;
    }
    return isVisualizeLoaded;
}

#pragma mark - UIWebView delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *callback = @"http://jaspermobile.callback/";
    NSString *debugger = @"http://debugger/";
    NSString *requestURLString = request.URL.absoluteString;
    NSLog(@"requestURLString: %@", requestURLString);

    if ([requestURLString rangeOfString:callback].length) {
        NSRange callbackRange = [requestURLString rangeOfString:callback];
        NSRange commandRange = NSMakeRange(callbackRange.length, requestURLString.length - callbackRange.length);
        NSString *command = [requestURLString substringWithRange:commandRange];
        if ([command rangeOfString:@"DOMContentLoaded"].length) {
            [self handleDOMContentLoaded];
        } else if ([command rangeOfString:@"runReport"].length) {
            [self handleRunReportWithJSCommand:command];
        } else if ([command rangeOfString:@"handleReferenceClick"].length) {
            [self handleReferenceClickWithJSCommand:command];
        } else if ([command rangeOfString:@"reportDidObtaineMultipageState"].length) {
            [self handleEventObtaineMultipageStateWithCommand:command];
        }   else if ([command rangeOfString:@"reportRunDidCompleted"].length) {
            [self handleEventReportRunDidCompletedWithCommand:command];
        } else if ([command rangeOfString:@"inputControls"].length) {
            [self handleInputControlsWithJSCommand:command];
        } else if([command rangeOfString:@"reportDidBeginRender"].length) {
            [self handleReportBeginRenderSuccessful];
        } else if([command rangeOfString:@"reportDidEndRenderSuccessful"].length) {
            [self handleReportEndRenderSuccessfull];
        } else if([command rangeOfString:@"reportDidEndRenderFailured"].length) {
            [self handleReportEndRenderFailedWithJSCommand:command];
        } else if ([command rangeOfString:@"reportDidChangePage"].length) {
            [self handleReportDidChangePageWithJSCommand:command];
        } else if ([command rangeOfString:@"linkOptions"].length) {
            [self handleLinkOptionsWithJSCommand:command];
        } else if ([command rangeOfString:@"error"].length) {
            [self handleErrorWithCommand:command];
        } else if ([command rangeOfString:@"exportPath"].length) {
            [self handleExportCommand:command];
        } else if ([command rangeOfString:@"reportDidDidEndRefreshSuccessful"].length) {
            [self handleRefreshDidEndSuccessful];
        } else if ([command rangeOfString:@"reportDidEndRefreshFailured"].length) {
            [self handleRefreshDidEndFailedWithJSCommand:command];
        }
        return NO;
    } else if ([requestURLString rangeOfString:debugger].length) {
        return NO;
    } else {
        // call to controller
        return YES;
    }
}

#pragma mark - DOM listeners
- (void)handleDOMContentLoaded
{
    // auth
    [self authenticate];
    [self fetchPageNumber:self.report.currentPage withCompletion:self.reportLoadCompletion];
}

- (void)authenticate
{
    NSString *runReportCommand = [NSString stringWithFormat:@"MobileReport.authorize({'username': '%@', 'password': '%@', 'organization': '%@'});", self.restClient.serverProfile.username, self.restClient.serverProfile.password, self.restClient.serverProfile.organization];
    [self.webView stringByEvaluatingJavaScriptFromString:runReportCommand];
}

#pragma mark - VisualizeJS error handlers
- (void)handleErrorWithCommand:(NSString *)command
{
    NSLog(@"handleErrorWithCommand: %@", command);
    // TODO: extend handle errors
}

#pragma mark - VisualizeJS handlers
- (void)handleReportBeginRenderSuccessful
{
    NSLog(@"report rendering begin");
}

- (void)handleReportEndRenderSuccessfull
{
    NSLog(@"report rendering end");

    [self.report updateLoadingStatusWithValue:YES];

    if (self.reportLoadCompletion) {
        self.reportLoadCompletion(YES, nil);
    }
}

- (void)handleReportEndRenderFailedWithJSCommand:(NSString *)command
{
    NSLog(@"report rendering failured with error: %@", command);

    NSDictionary *parameters = [self parseCommand:command];
    if (self.reportLoadCompletion) {
        NSString *errorString = parameters[@"error"];
        errorString = [errorString stringByRemovingPercentEncoding];
        JMReportLoaderErrorType errorType = JMReportLoaderErrorTypeUndefined;
        if (errorString && [errorString rangeOfString:@"authentication.error"].length) {
            errorType = JMReportLoaderErrorTypeAuthentification;
        }
        self.reportLoadCompletion(NO, [self createErrorWithType:errorType errorMessage:errorString]);
    }
}

- (void)handleEventReportRunDidCompletedWithCommand:(NSString *)command
{
    NSDictionary *params = [self parseCommand:command];

    NSInteger countOfPages = ((NSNumber *)params[@"pages"]).integerValue;
    [self.report updateCountOfPages:countOfPages];
}

- (void)handleExportCommand:(NSString *)command
{
    NSDictionary *params = [self parseCommand:command];

    NSString *outputResourcesPath = params[@"link"];
    if (outputResourcesPath) {
        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOutputResourcePath:fullReportName:)]) {
            NSString *fullReportName = [NSString stringWithFormat:@"%@.%@", self.report.resourceLookup.label, self.exportFormat];
            [self.delegate reportLoader:self didReceiveOutputResourcePath:outputResourcesPath fullReportName:fullReportName];
        }
    }
}

- (void)handleRefreshDidEndSuccessful
{
    NSLog(@"handleRefreshDidEndSuccessful");
    [self.report updateLoadingStatusWithValue:YES];

    if (self.reportLoadCompletion) {
        self.reportLoadCompletion(YES, nil);
    }
}

- (void)handleRefreshDidEndFailedWithJSCommand:(NSString *)command
{
    NSLog(@"handleRefreshDidEndFailedWithJSCommand: %@", command);
    if (self.reportLoadCompletion) {
        // TODO: add error
        self.reportLoadCompletion(NO, nil);
    }
}

#pragma mark - Visualize Helpers
- (NSDictionary *)parseCommand:(NSString *)command
{
    NSString *decodedCommand = [command stringByRemovingPercentEncoding];
    NSArray *components = [decodedCommand componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *component in components) {
        NSArray *keyValue = [component componentsSeparatedByString:@"="];
        if (keyValue.count == 2) {
            parameters[keyValue[0]] = keyValue[1];
        }
    }
    return parameters;
}

#pragma mark - Current page and Count of pages
- (void)handleReportDidChangePageWithJSCommand:(NSString *)command
{
    NSRange currentPageKeyRange = [command rangeOfString:@"&currentPage="];
    NSRange currentPageRange = NSMakeRange(currentPageKeyRange.length + currentPageKeyRange.location, command.length - (currentPageKeyRange.length + currentPageKeyRange.location));
    NSString *currentPageString = [command substringWithRange:currentPageRange];
    NSLog(@"current page: %@", currentPageString);
}

- (void)handleEventObtaineMultipageStateWithCommand:(NSString *)command
{
    NSDictionary *parameters = [self parseCommand:command];
    BOOL isMultiPage =((NSNumber *)parameters[@"isMultiPage"]).boolValue;
    [self.report updateIsMultiPageReport:isMultiPage];
}

#pragma mark - Input Controls (from visualize)
- (void)handleInputControlsWithJSCommand:(NSString *)command
{
    NSLog(@"command: %@", command);
}

#pragma mark - Hyperlinks handlers
- (void)handleLinkOptionsWithJSCommand:(NSString *)command
{
    // TODO: need refactor!!!
    //NSString *linkType = @"";
    //NSString *href = @"";
//    NSArray *components = [command componentsSeparatedByString:@"&"];
//    for (NSString *component in components) {
//        if ([component containsString:@"linkType"]) {
//            //linkType = [[component componentsSeparatedByString:@"="] lastObject];
//        } else if([component containsString:@"href"]) {
//            //href = [[component componentsSeparatedByString:@"="] lastObject];
//        }
//    }

    //JMWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMWebViewController"];
    //webViewController.urlString = href;
    //[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)handleReferenceClickWithJSCommand:(NSString *)command
{
    NSDictionary *parameters = [self parseCommand:command];
    NSLog(@"parameters: %@", parameters);

    NSString *locationString = parameters[@"location"];
    if (locationString) {
        NSURL *locationURL = [NSURL URLWithString:locationString];
        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForReference:)]) {
            [self.delegate reportLoader:self didReceiveOnClickEventForReference:locationURL];
        }
    }
}

- (void)handleRunReportWithJSCommand:(NSString *)command
{
    NSLog(@"hyperlink for run report");
    NSDictionary *parameters = [self parseCommand:command];
    NSLog(@"parameters: %@", parameters);

    NSString *params = parameters[@"params"];
    if (!params) {
        return;
    }
    NSData *jsonData = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];

    NSString *reportPath;
    if (json) {
        reportPath = json[@"_report"];

        if (reportPath) {
            [self.restClient resourceLookupForURI:reportPath resourceType:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT completionBlock:^(JSOperationResult *result) {
                NSError *error = result.error;
                if (error) {
                    NSLog(@"error: %@", error.localizedDescription);

                    NSString *errorString = error.localizedDescription;
                    JMReportLoaderErrorType errorType = JMReportLoaderErrorTypeUndefined;
                    if (errorString && [errorString rangeOfString:@"unauthorized"].length) {
                        errorType = JMReportLoaderErrorTypeAuthentification;
                    }
                    self.reportLoadCompletion(NO, [self createErrorWithType:errorType errorMessage:errorString]);
                } else {
                    NSLog(@"objects: %@", result.objects);
                    JSResourceLookup *resourceLookup = [result.objects firstObject];
                    if (resourceLookup) {
                        JMVisualizeReport *report = [JMVisualizeReport reportWithResource:resourceLookup inputControls:nil];

                        NSMutableDictionary *reportParameters = [NSMutableDictionary dictionary];
                        for (NSString *key in json.allKeys) {
                            if (![key isEqualToString:@"_report"]) {
                                reportParameters[key] = json[key];
                            }
                        }

                        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForReport:withParameters:)]) {
                            [self.delegate reportLoader:self didReceiveOnClickEventForReport:report withParameters:[reportParameters copy]];
                        }
                    }
                }
            }];
        }

    } else {
        NSLog(@"parse json with error: %@", jsonError.localizedDescription);
    }
}

@end
