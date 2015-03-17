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

typedef NS_ENUM(NSInteger, JMReportViewerAlertViewType) {
    JMReportViewerAlertViewTypeEmptyReport,
    JMReportViewerAlertViewTypeErrorLoad
};

NSString * const kJMReportVisualizeLoaderErrorDomain = @"JMReportVisualizeLoaderErrorDomain";

@interface JMVisualizeReportLoader()
@property (nonatomic, weak) JMVisualizeReport *report;
@property (nonatomic, strong) NSString *visualizePath;
@property (nonatomic, copy) void(^reportLoadCompletion)(BOOL success, NSError *error);
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
        // fix for servers lower 6.1
        if (self.restClient.serverProfile.serverInfo.versionAsFloat < 6.1) {
            visualizePath = [visualizePath stringByAppendingString:@"?_opt=false"];
        }
        _visualizePath = visualizePath;
    }
    return _visualizePath;
}

#pragma mark - Public API
- (void)fetchStartPageWithLoadHTMLCompletion:(void(^)(BOOL success, NSError *error))loadHTMLCompletion reportLoadCompletion:(void(^)(BOOL success, NSError *error))reportLoadCompletion
{
    [self.report updateCurrentPage:1]; // set start page
    self.isReportInLoadingProcess = YES;
    
    self.reportLoadCompletion = reportLoadCompletion;
    NSLog(@"visuzalise.js did start load");
    [self loadVisualizeJSWithCompletion:@weakself(^(BOOL success, NSError *error)){
        //self.isReportInLoadingProcess = NO;
        if (success) {
            NSLog(@"visuzalise.js did end load");
            NSString *baseURLString = self.restClient.serverProfile.serverUrl;
            [self.report updateHTMLString:[self htmlString] baseURLSring:baseURLString];
            if (loadHTMLCompletion) {
                loadHTMLCompletion(YES, nil);
            }
        } else {
            // TODO: handle this error
            NSLog(@"Error loading visualize.js");
            // TODO: add error code
            NSError *error = [NSError errorWithDomain:kJMReportVisualizeLoaderErrorDomain
                                                 code:0
                                             userInfo:nil];
            if (loadHTMLCompletion) {
                loadHTMLCompletion(NO, error);
            }
        }
    }@weakselfend];
}

- (void)loadPageNumber:(NSInteger)pageNumber withLoadHTMLCompletion:(void(^)(BOOL success, NSError *error))loadHTMLCompletion reportLoadCompletion:(void(^)(BOOL success, NSError *error))reportLoadCompletion
{
    NSString *setPageCommand = [NSString stringWithFormat:@"JasperMobile.report.setPage(%@)", @(pageNumber).stringValue];
    [self.report updateCurrentPage:pageNumber];
    [self.webView stringByEvaluatingJavaScriptFromString:setPageCommand];
}

- (void)reloadReportWithInputControls:(NSArray *)inputControls
{
    [self.report updateCurrentPage:1]; // set start page
    NSString *parametersAsString = [self createParametersAsStringFromInputControls:inputControls];
    NSString *runReportCommand = [NSString stringWithFormat:@"JasperMobile.report.run(reportPath, %@);", parametersAsString];
    [self.webView stringByEvaluatingJavaScriptFromString:runReportCommand];
}

- (void) cancelReport
{
    // TODO: need cancel?
}

#pragma mark - Helpers
- (NSString *)htmlString
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"visualize_test" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    // Visualize
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"VISUALIZE_PATH" withString:self.visualizePath];
    
    // JasperMobile
    NSString *jaspermobilePath = [[NSBundle mainBundle] pathForResource:@"jaspermobile" ofType:@"js"];
    NSString *jaspermobileString = [NSString stringWithContentsOfFile:jaspermobilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *reportPath = [NSString stringWithFormat:@"\"%@\"", self.report.reportURI];
    jaspermobileString = [jaspermobileString stringByReplacingOccurrencesOfString:@"REPORT_PATH" withString:reportPath];
    
    // auth
    NSString *authName = [NSString stringWithFormat:@"\"%@\"", self.restClient.serverProfile.username];
    NSString *authPassword = [NSString stringWithFormat:@"\"%@\"", self.restClient.serverProfile.password];
    NSString *authOrganisation = [NSString stringWithFormat:@"\"%@\"", self.restClient.serverProfile.organization];
    
    jaspermobileString = [jaspermobileString stringByReplacingOccurrencesOfString:@"AUTH_NAME" withString:authName];
    jaspermobileString = [jaspermobileString stringByReplacingOccurrencesOfString:@"AUTH_PASSWORD" withString:authPassword];
    jaspermobileString = [jaspermobileString stringByReplacingOccurrencesOfString:@"AUTH_ORGANISATION" withString:authOrganisation];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"JASPERMOBILE_SCRIPT" withString:jaspermobileString];
    
    NSString *parametersAsString = [self createParametersAsStringFromInputControls:self.report.inputControls];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"REPORT_PARAMETERS"
                                                       withString:parametersAsString];
    
    return htmlString;
}

- (NSDictionary *)reportParametersWithInputControls:(NSArray *)inputControls
{
    NSMutableDictionary *reportParameters = [NSMutableDictionary dictionary];
    for (JSInputControlDescriptor *inputControl in inputControls) {
        if (inputControl.state.uuid && [inputControl.selectedValues firstObject]) {
            reportParameters[inputControl.state.uuid] = inputControl.selectedValues;
        }
    }
    return [reportParameters copy];
}

- (NSString *)createParametersAsStringFromInputParameters:(NSDictionary *)inputParameters
{
    NSMutableString *parametersAsString = [@"{" mutableCopy];
    for (NSString *key in inputParameters.allKeys) {
        id value = inputParameters[key];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *values = value;
            NSString *stringValues = @"";
            for (NSString *value in values) {
                stringValues = [stringValues stringByAppendingFormat:@"\"%@\",", value];
            }
            [parametersAsString appendFormat:@"\"%@\":[%@],", key, stringValues];
        } else {
            [parametersAsString appendFormat:@"\"%@\":[\"%@\"],", key, value];
        }
    }
    [parametersAsString appendString:@"}"];
    return [parametersAsString copy];
}

- (NSString *)createParametersAsStringFromInputControls:(NSArray *)inputControls
{
    NSDictionary *inputParameters = [self reportParametersWithInputControls:inputControls];
    NSMutableString *parametersAsString = [@"{" mutableCopy];
    for (NSString *key in inputParameters.allKeys) {
        id value = inputParameters[key];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *values = value;
            NSString *stringValues = @"";
            for (NSString *value in values) {
                stringValues = [stringValues stringByAppendingFormat:@"\"%@\",", value];
            }
            [parametersAsString appendFormat:@"\"%@\":[%@],", key, stringValues];
        } else {
            [parametersAsString appendFormat:@"\"%@\":[\"%@\"],", key, value];
        }
    }
    [parametersAsString appendString:@"}"];
    return [parametersAsString copy];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        
        NSURLRequest *visualizeJSRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.visualizePath]];
        NSData *data = [NSURLConnection sendSynchronousRequest:visualizeJSRequest returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
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
        });
    });
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
    // containsString in ios8
    //NSRange callbackRange = [requestURLString rangeOfString:callback];
    NSLog(@"requestURLString: %@", requestURLString);
    if ([requestURLString rangeOfString:callback].length) {
        NSRange callbackRange = [requestURLString rangeOfString:callback];
        NSRange commandRange = NSMakeRange(callbackRange.length, requestURLString.length - callbackRange.length);
        NSString *command = [requestURLString substringWithRange:commandRange];
        if ([command rangeOfString:@"runReport"].length) {
            [self handleRunReportWithJSCommand:command];
        } else if ([command rangeOfString:@"changeTotalPages"].length) {
            [self handleEventTotalPageDidChangeWithCommand:command];
        } else if ([command rangeOfString:@"inputControls"].length) {
            [self handleInputControlsWithJSCommand:command];
        } else if([command rangeOfString:@"reportDidBeginRender"].length) {
            [self handleReportBeginRenderSuccessfull];
        } else if([command rangeOfString:@"reportDidEndRenderSuccessful"].length) {
            [self handleReportEndRenderSuccessfull];
        } else if([command rangeOfString:@"reportDidEndRenderFailured"].length) {
            [self handleReportEndRenderFailured];
        } else if ([command rangeOfString:@"reportDidChangePage"].length) {
            [self handleReportDidChangePageWithJSCommand:command];
        } else if ([command rangeOfString:@"linkOptions"].length) {
            [self handleLinkOptionsWithJSCommand:command];
        } else if ([command rangeOfString:@"error"].length) {
            [self handleErrorWithCommand:command];
        }
        return NO;
    } else if ([requestURLString rangeOfString:debugger].length) {
        return NO;
    } else {
        // call to controller
        return YES;
    }
}

#pragma mark - VisualizeJS error handlers
- (void)handleErrorWithCommand:(NSString *)command
{
    // TODO: extend handle errors
    NSDictionary *components = [self parseCommand:command];
    
    NSString *messageError = [components[@"message"] stringByRemovingPercentEncoding];
    UIAlertView *alertView = [UIAlertView localizedAlertWithTitle:@"report.viewer.error.title"
                                                          message:messageError
                                                         delegate:self
                                                cancelButtonTitle:@"dialog.button.ok"
                                                otherButtonTitles: nil];
    alertView.tag = JMReportViewerAlertViewTypeErrorLoad;
    //[alertView show];
}

#pragma mark - VisualizeJS handlers
- (void)handleReportBeginRenderSuccessfull
{
    NSLog(@"report rendering begin");
}

- (void)handleReportEndRenderSuccessfull
{
    NSLog(@"report rendering end");
    
    if (!self.report.isReportEmpty) {
        self.reportLoadCompletion(YES, nil);
    }
}

- (void)handleReportEndRenderFailured
{
    NSLog(@"report rendering failured");
    if (self.reportLoadCompletion) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : JMCustomLocalizedString(@"report.viewer.visualize.render.error", nil) };
        NSError *error = [NSError errorWithDomain:kJMReportVisualizeLoaderErrorDomain
                                             code:JMReportLoaderErrorTypeUndefined
                                         userInfo:userInfo];
        self.reportLoadCompletion(NO, error);
    }
}

#pragma mark - Visualize Helpers
- (NSDictionary *)parseCommand:(NSString *)command
{
    NSArray *components = [command componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *component in components) {
        if ([component containsString:@"type"]) {
            // TODO: need any action?
            continue;
        }
        NSArray *keyValue = [component componentsSeparatedByString:@"="];
        parameters[keyValue[0]] = keyValue[1];
    }
    return parameters;
}

#pragma mark - Current page and Count of pages
- (void)handleReportDidChangePageWithJSCommand:(NSString *)command
{
    // NSLog(@"command: %@", command);
    NSRange currentPageKeyRange = [command rangeOfString:@"&currentPage="];
    NSRange currentPageRange = NSMakeRange(currentPageKeyRange.length + currentPageKeyRange.location, command.length - (currentPageKeyRange.length + currentPageKeyRange.location));
    NSString *currentPageString = [command substringWithRange:currentPageRange];
    //NSInteger currentPage = currentPageString.integerValue;
    //self.toolbar.currentPage = currentPage;
    NSLog(@"current page: %@", currentPageString);
}

- (void)handleEventTotalPageDidChangeWithCommand:(NSString *)command
{
    
    NSRange totalPageKeyRange = [command rangeOfString:@"&totalPage="];
    NSRange totalPageRange = NSMakeRange(totalPageKeyRange.length + totalPageKeyRange.location, command.length - (totalPageKeyRange.length + totalPageKeyRange.location));
    NSString *totalPageString = [command substringWithRange:totalPageRange];
    NSInteger totalPage = totalPageString.integerValue;
    NSLog(@"total of pages: %@", @(totalPage));
    
    [self.report updateCountOfPages:totalPage];
    if (totalPage == 0) {
        NSInteger code = JMReportLoaderErrorTypeEmtpyReport;
        NSDictionary *userInfo = nil;
        NSError *error = [NSError errorWithDomain:kJMReportVisualizeLoaderErrorDomain
                                             code:code
                                         userInfo:userInfo];
        self.reportLoadCompletion(NO, error);
    } else {
        [self.report saveCurrentState];
    }
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
    NSArray *components = [command componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        if ([component containsString:@"linkType"]) {
            //linkType = [[component componentsSeparatedByString:@"="] lastObject];
        } else if([component containsString:@"href"]) {
            //href = [[component componentsSeparatedByString:@"="] lastObject];
        }
    }
    
    //JMWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMWebViewController"];
    //webViewController.urlString = href;
    //[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)handleRunReportWithJSCommand:(NSString *)command
{
    //NSLog(@"hyperlink for run report");
    
    NSString *decodedCommand = [command stringByRemovingPercentEncoding];
    NSDictionary *parameters = [self parseCommand:decodedCommand];
    //NSLog(@"parameters: %@", parameters);
    
    NSString *reportPath = parameters[@"reportPath"];
    if (reportPath) {        
        [self.restClient resourceLookupForURI:reportPath resourceType:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT completionBlock:^(JSOperationResult *result) {
            NSLog(@"objects: %@", result.objects);
            JSResourceLookup *resourceLookup = [result.objects firstObject];
            if (resourceLookup) {
                JMVisualizeReport *report = [JMVisualizeReport reportWithResource:resourceLookup inputControls:nil];
                
                NSMutableDictionary *reportParameters = [NSMutableDictionary dictionary];
                for (NSString *key in parameters.allKeys) {
                    if (![key isEqualToString:@"reportPath"]) {
                        reportParameters[key] = parameters[key];
                    }
                }
                
                if ([self.delegate respondsToSelector:@selector(reportLoader:didReciveOnClickEventForReport:withParameters:)]) {
                    [self.delegate reportLoader:self didReciveOnClickEventForReport:report withParameters:[reportParameters copy]];
                }
            }
        }];
    }
}

@end
