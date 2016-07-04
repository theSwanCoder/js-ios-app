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
#import "JMVIZWebEnvironment.h"
#import "JMResource.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptNativeBridge.h"
#import "JMReportBookmark.h"
#import "JMReportPart.h"

@interface JMVisualizeReportLoader()
@property (nonatomic, weak, readwrite) JMReport *report;
@property (nonatomic, assign, readwrite) BOOL isReportInLoadingProcess;
@property (nonatomic, copy) NSString *exportFormat;
@property (nonatomic, weak) JMVIZWebEnvironment *webEnvironment;
@property (nonatomic, assign, getter=isCancelLoading) BOOL cancelLoading;
@end

@implementation JMVisualizeReportLoader

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient
{
    self = [super init];
    if (self) {
        _report = (JMReport *)report;
        _report.bookmarks = nil;
    }
    return self;
}

+ (instancetype)loaderWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient {
    return [[self alloc] initWithReport:report restClient:restClient];
}

- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (id<JMReportLoaderProtocol>)initWithReport:(nonnull JSReport *)report
                                  restClient:(nonnull JSRESTBase *)restClient
                              webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [self initWithReport:report restClient:restClient];
    if (self) {
        NSAssert([webEnvironment isKindOfClass:[JMVIZWebEnvironment class]], @"WebEnvironment isn't correct class");
        _webEnvironment = (JMVIZWebEnvironment *) webEnvironment;
        [self addListenersForVisualizeEvents];
    }
    return self;
}

+ (id<JMReportLoaderProtocol>)loaderWithReport:(nonnull JSReport *)report
                                    restClient:(nonnull JSRESTBase *)restClient
                                webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithReport:report
                             restClient:restClient
                         webEnvironment:webEnvironment];
}

#pragma mark - Public API
- (void)runReportWithPage:(NSInteger)page completion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.cancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];
    if (self.report.isReportAlreadyLoaded) {
        [self freshLoadReportWithPageNumber:page
                                       completion:heapBlock];
    } else {
        __weak __typeof(self) weakSelf = self;
        [self.webEnvironment prepareWithCompletion:^(BOOL isReady, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (strongSelf.cancelLoading) {
                return;
            }
            if (isReady) {
                [strongSelf freshLoadReportWithPageNumber:page
                                               completion:heapBlock];
            } else {
                heapBlock(NO, [strongSelf loaderErrorFromBridgeError:error]);
            }
        }];
    }
}

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.isCancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.navigateTo"
                                                                parameters:@{
                                                                        @"destination" : @(pageNumber)
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.isCancelLoading) {
                                            return;
                                        }
                                        if (error) {
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            NSNumber *page = parameters[@"destination"];
                                            [strongSelf.report updateCurrentPage:page.integerValue];
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)applyReportParametersWithCompletion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.isCancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];
    if (self.report.isReportAlreadyLoaded) {
        [self.report updateCurrentPage:1];
        [self.report updateCountOfPages:NSNotFound];

        JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.applyReportParams"
                                                                    parameters:[self runParameters]];
        __weak __typeof(self) weakSelf = self;
        [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                heapBlock(NO, vizError);
            } else {
                if (parameters[@"pages"]) {
                    NSInteger countOfPages = ((NSNumber *)parameters[@"pages"]).integerValue;
                    [strongSelf.report updateCountOfPages:countOfPages];
                } else {
#ifndef __RELEASE__
                    NSError *absentPagesError = [NSError errorWithDomain:@"Visualize Error" code:0 userInfo:@{
                            NSLocalizedDescriptionKey : @"Absent of pages after applying report parameters"
                    }];
                    [JMUtils presentAlertControllerWithError:absentPagesError
                                                  completion:nil];
#endif
                }
                heapBlock(YES, nil);
            }
        }];

    } else {
        __weak __typeof(self) weakSelf = self;
        [self.webEnvironment prepareWithCompletion:^(BOOL isReady, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (strongSelf.cancelLoading) {
                return;
            }
            if (isReady) {
                [strongSelf freshLoadReportWithPageNumber:self.report.currentPage
                                               completion:heapBlock];
            } else {
                heapBlock(NO, [strongSelf loaderErrorFromBridgeError:error]);
            }
        }];
    }
}

- (void)refreshReportWithCompletion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.cancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    // need for clean running, but not selecting page
    self.report.isReportAlreadyLoaded = NO;
    [self.report updateCountOfPages:NSNotFound];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.VIS.API.refresh";

    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                            completion:^(NSDictionary *parameters, NSError *error) {
                                __typeof(self) strongSelf = weakSelf;
                                if (strongSelf.cancelLoading) {
                                    return;
                                }
                                if (error) {
                                    heapBlock(NO, [strongSelf loaderErrorFromBridgeError:error]);
                                } else {
                                    strongSelf.report.isReportAlreadyLoaded = YES;
                                    [strongSelf.report updateCurrentPage:1];
                                    heapBlock(YES, nil);
                                }
                            }];
}

- (void)navigateToBookmark:(JMReportBookmark *__nonnull)bookmark withCompletion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.cancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.navigateTo"
                                                                parameters:@{
                                                                        @"destination" : @{
                                                                                @"anchor" : bookmark.anchor
                                                                        }
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.cancelLoading) {
                                            return;
                                        }
                                        if (error) {
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)navigateToPart:(JMReportPart *__nonnull)part withCompletion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.cancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.navigateTo"
                                                                parameters:@{
                                                                        @"destination" : part.page
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.cancelLoading) {
                                            return;
                                        }
                                        if (error) {
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            NSNumber *page = parameters[@"destination"];
                                            [strongSelf.report updateCurrentPage:page.integerValue];
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)cancel
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.cancelLoading = YES;

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.cancel"
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"canceling report was finished");
            self.report.isReportAlreadyLoaded = NO;
            [self.webEnvironment removeAllListeners];
        }
    }];
}

- (void)destroy
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (self.isCancelLoading) {
        return;
    }

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.destroy"
                                                                parameters:nil];

    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        JMLog(@"finish of destroying");
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", parameters);
            self.report.isReportAlreadyLoaded = NO;
            [self.webEnvironment removeAllListeners];
        }
    }];
}

- (void)fitReportViewToScreen
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Report.VIS.API.fitReportViewToScreen";
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:nil];
}

#pragma mark - Private

- (void)freshLoadReportWithPageNumber:(NSInteger)pageNumber completion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");

    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (!self.report) {
        return;
    }

    if (self.isCancelLoading) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    // need for clean running, but not selecting page
    self.report.isReportAlreadyLoaded = NO;
    self.isReportInLoadingProcess = YES;

    [self.report updateCountOfPages:NSNotFound];
    [self.report updateCurrentPage:pageNumber];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.VIS.API.run"
                                                                parameters: @{
                                                                        @"uri"        : self.report.reportURI,
                                                                        @"params"     : [self runParameters],
                                                                        @"pages"      : @(pageNumber),
                                                                        @"is_for_6_0" : @([JMUtils isServerAmber]),
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.isCancelLoading) {
                                            return;
                                        }
                                        strongSelf.isReportInLoadingProcess = NO;
                                        if (error) {
                                            JMLog(@"have error");
                                            JMLog(@"send the error to viewer");
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            strongSelf.report.isReportAlreadyLoaded = YES;
                                            NSString *status = parameters[@"status"];
                                            NSNumber *currentPage = parameters[@"currentPage"];
                                            NSNumber *totalPages = parameters[@"totalPages"];

                                            if ([status isEqualToString:@"ready"]) {
                                                [strongSelf.report updateCurrentPage:currentPage.integerValue];
                                                [strongSelf.report updateCountOfPages:totalPages.integerValue];
                                            } else {
                                                if (currentPage) {
                                                    [strongSelf.report updateCurrentPage:currentPage.integerValue];
                                                }
                                            }

                                            NSArray *bookmarks = parameters[@"bookmarks"];
                                            if (bookmarks && [bookmarks isKindOfClass:[NSArray class]]) {
                                                strongSelf.report.bookmarks = [strongSelf mapBookmarksFromParams:bookmarks];
                                            }

                                            NSArray *parts = parameters[@"parts"];
                                            if (parts && [parts isKindOfClass:[NSArray class]]) {
                                                strongSelf.report.parts = [strongSelf mapReportPartsFromParams:parts];
                                            }

                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)addListenersForVisualizeEvents
{
    // Life Cycle

    NSString *reportCompletedListenerId = @"JasperMobile.Report.Event.reportCompleted";
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment addListenerWithId:reportCompletedListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(reportCompletedListenerId);
        __typeof(self) strongSelf = weakSelf;
        // TODO: move into separate method
        NSInteger countOfPages = ((NSNumber *)parameters[@"pages"]).integerValue;
        [strongSelf.report updateCountOfPages:countOfPages];
    }];
    NSString *changePagesStateListenerId = @"JasperMobile.Report.Event.changePagesState";
    [self.webEnvironment addListenerWithId:changePagesStateListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(changePagesStateListenerId);
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = parameters[@"page"];
        [strongSelf.report updateCurrentPage:locationString.integerValue];
    }];
    NSString *bookmarsReadyListenerId = @"JasperMobile.Report.Event.bookmarksReady";
    [self.webEnvironment addListenerWithId:bookmarsReadyListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(bookmarsReadyListenerId);
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            // TODO: handle error
        } else {
            if (parameters[@"bookmarks"]) {
                NSArray *bookmarks = [strongSelf mapBookmarksFromParams:parameters[@"bookmarks"]];
                strongSelf.report.bookmarks = bookmarks;
            } else {
                // empty array;
            }
        }
    }];
    NSString *partsReadyListenerId = @"JasperMobile.Report.Event.reportPartsReady";
    [self.webEnvironment addListenerWithId:partsReadyListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(partsReadyListenerId);
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            // TODO: handle error
        } else {
            if (parameters[@"parts"]) {
                NSArray *parts = [strongSelf mapReportPartsFromParams:parameters[@"parts"]];
                strongSelf.report.parts = parts;
            } else {
                // empty array;
            }
        }
    }];

    // Hyperlinks

    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.Report.VIS.API.Event.Link.ReportExecution";
    [self.webEnvironment addListenerWithId:reportExecutionLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(reportExecutionLinkOptionListenerId);
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleRunReportWithParameters:parameters];
    }];
    NSString *localPageLinkOptionListenerId = @"JasperMobile.Report.VIS.API.Event.Link.LocalPage";
    [self.webEnvironment addListenerWithId:localPageLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(localPageLinkOptionListenerId);
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = parameters[@"destination"];
        [strongSelf.report updateCurrentPage:locationString.integerValue];
    }];
    NSString *localAnchorLinkOptionListenerId = @"JasperMobile.Report.VIS.API.Event.Link.LocalAnchor";
    [self.webEnvironment addListenerWithId:localAnchorLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(localAnchorLinkOptionListenerId);
    }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.Report.VIS.API.Event.Link.Reference";
    [self.webEnvironment addListenerWithId:referenceLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(referenceLinkOptionListenerId);
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = parameters[@"destination"];
        if (locationString) {
            NSURL *locationURL = [NSURL URLWithString:locationString];
            if ([strongSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForReference:)]) {
                [strongSelf.delegate reportLoader:strongSelf didReceiveOnClickEventForReference:locationURL];
            }
        }
    }];
    NSString *remoteAnchorListenerId = @"JasperMobile.Report.VIS.API.Event.Link.RemoteAnchor";
    [self.webEnvironment addListenerWithId:remoteAnchorListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(remoteAnchorListenerId);
        __typeof(self) strongSelf = weakSelf;
        JMLog(@"parameters: %@", parameters);
        NSDictionary *link = parameters[@"link"];
        if (link && [link isKindOfClass:[NSDictionary class]]) {
            NSString *href = link[@"href"];
            if (href) {
                NSString *prefix = [href substringWithRange:NSMakeRange(0, 1)];
                if ([prefix isEqualToString:@"."]) {
                    href = [href stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
                }
                NSString *fullURLString = [strongSelf.restClient.serverProfile.serverUrl stringByAppendingString:href];
                JMLog(@"full url string: %@", fullURLString);
                NSURL *locationURL = [NSURL URLWithString:fullURLString];
                if ([strongSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForReference:)]) {
                    [strongSelf.delegate reportLoader:strongSelf didReceiveOnClickEventForReference:locationURL];
                }
            }
        }
    }];
    NSString *remotePageListenerId = @"JasperMobile.Report.VIS.API.Event.Link.RemotePage";
    [self.webEnvironment addListenerWithId:remotePageListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(remotePageListenerId);
        __typeof(self) strongSelf = weakSelf;
        JMLog(@"parameters: %@", parameters);
    }];
}

#pragma mark - Helpers
- (NSDictionary *)runParameters
{
    NSMutableDictionary *runParams = [@{} mutableCopy];
    for (JSReportParameter *parameter in self.report.reportParameters) {
        runParams[parameter.name] = parameter.value;
    }
    return runParams;
}

#pragma mark - Hyperlinks handlers
- (void)handleRunReportWithParameters:(NSDictionary *)parameters
{
    NSDictionary *params = parameters[@"data"];
    if (!params) {
        return;
    }

    NSString *reportPath = params[@"resource"];
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

                    JMResource *resource = [JMResource resourceWithResourceLookup:resourceLookup];
                    if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForResource:withParameters:)]) {
                        [self.delegate reportLoader:self didReceiveOnClickEventForResource:resource withParameters:[reportParameters copy]];
                    }
                }
            }
        }];
    }
}

- (NSError *)createErrorWithType:(JSReportLoaderErrorType)errorType errorMessage:(NSString *)errorMessage
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorMessage ?: JMCustomLocalizedString(@"report_viewer_visualize_render_error", nil) };
    NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                         code:errorType
                                     userInfo:userInfo];
    return error;
}

#pragma mark - Bookmarks Handler
- (NSArray *)mapBookmarksFromParams:(NSArray *__nonnull)params
{
    NSAssert(params != nil, @"parameters is nil");
    NSAssert([params isKindOfClass:[NSArray class]], @"Parameters should be NSArray class");

    NSMutableArray *bookmarks = [NSMutableArray new];

    for (NSDictionary *bookmarkData in params) {
        // TODO: how handle empty fields?
        NSString *anchor = bookmarkData[@"anchor"];
        NSNumber *page = bookmarkData[@"page"];
        NSArray *nestedBookmarks;
        NSArray *nestedBoomarksDataArray = bookmarkData[@"bookmarks"];
        if ([nestedBoomarksDataArray isKindOfClass:[NSArray class]]) {
            nestedBookmarks = [self mapBookmarksFromParams:nestedBoomarksDataArray];
        }
        JMReportBookmark *bookmark = [JMReportBookmark bookmarkWithAnchor:anchor page:page];
        bookmark.bookmarks = nestedBookmarks;
        [bookmarks addObject:bookmark];
    }

    return bookmarks;
}

#pragma mark - Handle Report Parts (Workbooks)
- (NSArray *)mapReportPartsFromParams:(NSArray *__nonnull)params
{
    NSAssert(params != nil, @"parameters is nil");
    NSAssert([params isKindOfClass:[NSArray class]], @"Parameters should be NSArray class");

    NSMutableArray *parts = [NSMutableArray new];

    for (NSDictionary *reportPartData in params) {
        // TODO: how handle empty fields?
        NSString *name = reportPartData[@"name"];
        NSNumber *page = reportPartData[@"page"];
        JMReportPart *part = [[JMReportPart alloc] initWithName:name page:page];
        [parts addObject:part];
    }

    return parts;
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
