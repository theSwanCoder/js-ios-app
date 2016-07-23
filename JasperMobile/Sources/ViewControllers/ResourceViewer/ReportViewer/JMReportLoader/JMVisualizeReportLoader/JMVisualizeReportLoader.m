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
#import "JMJavascriptRequestExecutor.h"
#import "JSReportDestination.h"
#import "JSReportBookmark.h"
#import "JSReportPart.h"
#import "JMHyperlink.h"

@interface JMVisualizeReportLoader()
@property (nonatomic, assign, readwrite) JSReportLoaderState state;
@property (nonatomic, strong, readwrite) JSReport *report;
@property (nonatomic, copy) JSRESTBase *restClient;

@property (nonatomic, weak) JMVIZWebEnvironment *webEnvironment;
@end

@implementation JMVisualizeReportLoader

#pragma mark - Lifecycle
- (instancetype)initWithRestClient:(JSRESTBase *)restClient
{
    self = [super init];
    if (self) {
        JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
        _restClient = [restClient copy];
        _state = JSReportLoaderStateInitial;
    }
    return self;
}

+ (instancetype)loaderWithRestClient:(JSRESTBase *)restClient {
    return [[self alloc] initWithRestClient:restClient];
}

- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (id<JMReportLoaderProtocol>)initWithRestClient:(nonnull JSRESTBase *)restClient
                                  webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [self initWithRestClient:restClient];
    if (self) {
        JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
        NSAssert([webEnvironment isKindOfClass:[JMVIZWebEnvironment class]], @"WebEnvironment isn't correct class");
        _webEnvironment = (JMVIZWebEnvironment *) webEnvironment;
        [self addListenersForVisualizeEvents];
    }
    return self;
}

+ (id<JMReportLoaderProtocol>)loaderWithRestClient:(nonnull JSRESTBase *)restClient
                                    webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithRestClient:restClient
                             webEnvironment:webEnvironment];
}

#pragma mark - JSReportLoaderProtocol Public API
- (void)runReport:(nonnull JSReport *)report
      initialPage:(nullable NSNumber *)initialPage
initialParameters:(nullable NSArray <JSReportParameter *> *)initialParameters
       completion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JSReportDestination *destination = [JSReportDestination new];

    if (initialPage) {
        NSAssert(![initialPage isKindOfClass:[NSNumber class]], @"Wrong class of initial page value");
        destination.page = initialPage.integerValue;
    } else {
        destination.page = 1;
    }

    [self runReport:report
 initialDestination:destination
  initialParameters:initialParameters
         completion:completion];

}

- (void)runReportWithReportURI:(nonnull NSString *)reportURI
                   initialPage:(nullable NSNumber *)initialPage
             initialParameters:(nullable NSArray <JSReportParameter *> *)initialParameters
                    completion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.uri = reportURI;
    JSReport *report = [JSReport reportWithResourceLookup:resourceLookup];

    [self runReport:report
        initialPage:initialPage
  initialParameters:initialParameters
         completion:completion];
}

- (void)fetchPage:(nonnull NSNumber *)page
       completion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");
    NSAssert(page != nil, @"page is nil");

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    self.state = JSReportLoaderStateLoading;

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.navigateTo"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:@{
                                                                        @"destination" : @(page.integerValue)
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.state == JSReportLoaderStateCancel) {
                                            return;
                                        }
                                        if (error) {
                                            strongSelf.state = JSReportLoaderStateFailed;
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            strongSelf.state = JSReportLoaderStateReady;
                                            NSNumber *finishPage = parameters[@"destination"];
                                            [strongSelf.report updateCurrentPage:finishPage.integerValue];
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)applyReportParameters:(nullable NSArray <JSReportParameter *> *)parameters
                   completion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    [self.report updateCurrentPage:1];
    [self.report updateCountOfPages:NSNotFound];
    self.report.reportParameters = parameters;

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.applyReportParams"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:[self configureParameters:parameters]];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
            heapBlock(NO, vizError);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)refreshReportWithCompletion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    [self.report restoreDefaultState];
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    self.state = JSReportLoaderStateLoading;

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refresh"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.state == JSReportLoaderStateCancel) {
                                            return;
                                        }
                                        if (error) {
                                            strongSelf.state = JSReportLoaderStateFailed;
                                            heapBlock(NO, [strongSelf loaderErrorFromBridgeError:error]);
                                        } else {
                                            strongSelf.state = JSReportLoaderStateReady;
                                            [strongSelf.report updateCurrentPage:1];
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)cancel
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.state = JSReportLoaderStateCancel;
    [self removeListenersForVisualizeEvents];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.cancel"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"canceling report was finished");
        }
    }];
}

- (void)reset
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self cancel];
    self.report = nil;
    self.state = JSReportLoaderStateInitial;
}

// TODO: need this?
- (BOOL) shouldDisplayLoadingView
{
    return YES;
}

#pragma mark - JMReportLoaderProtocol Public API

- (void)runReport:(nonnull JSReport *)report
initialDestination:(nullable JSReportDestination *)destination
        initialParameters:(nullable NSArray <JSReportParameter *> *)initialParameters
        completion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(report != nil, @"Report is nil");

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    self.report = report;
    self.report.reportParameters = initialParameters;
    self.state = JSReportLoaderStateConfigured;
    [self freshLoadReportWithDestination:destination
                              parameters:initialParameters
                              completion:completion];
}

- (void)navigateToBookmark:(nonnull JSReportBookmark *)bookmark
                completion:(nonnull JSReportLoaderCompletionBlock)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    self.state = JSReportLoaderStateLoading;

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.navigateTo"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:@{
                                                                        @"destination" : @{
                                                                                @"anchor" : bookmark.anchor
                                                                        }
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.state == JSReportLoaderStateCancel) {
                                            return;
                                        }
                                        if (error) {
                                            strongSelf.state = JSReportLoaderStateFailed;
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            strongSelf.state = JSReportLoaderStateReady;
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)navigateToPart:(JSReportPart *__nonnull)part completion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.report != nil, @"Report is nil");

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    self.state = JSReportLoaderStateLoading;

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.navigateTo"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:@{
                                                                        @"destination" : part.page
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.state == JSReportLoaderStateCancel) {
                                            return;
                                        }
                                        if (error) {
                                            strongSelf.state = JSReportLoaderStateFailed;
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            strongSelf.state = JSReportLoaderStateReady;
                                            NSNumber *page = parameters[@"destination"];
                                            [strongSelf.report updateCurrentPage:page.integerValue];
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)destroy
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    [self removeListenersForVisualizeEvents];
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.destroy"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];

    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        JMLog(@"finish of destroying");
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", parameters);
            self.state = JSReportLoaderStateInitial;
        }
    }];
}

- (void)fitReportViewToScreen
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.fitReportViewToScreen"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:nil];
}

#pragma mark - Private
- (void)freshLoadReportWithDestination:(JSReportDestination *)destination
                            parameters:(NSArray <JSReportParameter *>*)parameters
                            completion:(JSReportLoaderCompletionBlock __nonnull)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");

    if (!self.report) {
        return;
    }

    if (self.state == JSReportLoaderStateCancel) {
        return;
    }

    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    [self.report updateCurrentPage:destination.page];

    id pages;
    if (destination.anchor) {
        pages =  @{
                @"anchor" : destination.anchor,
        };
    } else {
        pages = @(destination.page);
    }

    self.state = JSReportLoaderStateLoading;
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.run"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters: @{
                                                                        @"uri"        : self.report.reportURI,
                                                                        @"params"     : [self configureParameters:parameters],
                                                                        @"pages"      : pages,
                                                                        @"is_for_6_0" : @([JMUtils isServerAmber]),
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        JMLog(@"parameters: %@", parameters);
                                        __typeof(self) strongSelf = weakSelf;
                                        if (strongSelf.state == JSReportLoaderStateCancel) {
                                            return;
                                        }
                                        if (error) {
                                            JMLog(@"have error");
                                            JMLog(@"send the error to viewer");
                                            strongSelf.state = JSReportLoaderStateFailed;
                                            NSError *vizError = [strongSelf loaderErrorFromBridgeError:error];
                                            heapBlock(NO, vizError);
                                        } else {
                                            strongSelf.state = JSReportLoaderStateReady;
                                            NSString *status = parameters[@"status"];
                                            if ([status isEqualToString:@"ready"]) {
                                                NSNumber *totalPages = parameters[@"totalPages"];
                                                [strongSelf.report updateCountOfPages:totalPages.integerValue];
                                            }

                                            id finishPages = parameters[@"pages"];
                                            if (finishPages) {
                                                if ([finishPages isKindOfClass:[NSNumber class]]) {
                                                    [strongSelf.report updateCurrentPage:[finishPages integerValue]];
                                                } else if ([finishPages isKindOfClass:[NSDictionary class]]) {
                                                    // TODO: need handle anchors? and how?
                                                }
                                            }

                                            NSArray *bookmarks = parameters[@"bookmarks"];
                                            if (bookmarks && [bookmarks isKindOfClass:[NSArray class]] && bookmarks.count > 0) {
                                                strongSelf.report.bookmarks = [strongSelf mapBookmarksFromParams:bookmarks];
                                            }

                                            NSArray *parts = parameters[@"parts"];
                                            if (parts && [parts isKindOfClass:[NSArray class]] && parts.count > 0) {
                                                strongSelf.report.parts = [strongSelf mapReportPartsFromParams:parts];
                                            }

                                            heapBlock(YES, nil);
                                        }
                                    }];
}

- (void)addListenersForVisualizeEvents
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    // Life Cycle

    NSString *reportCompletedListenerId = @"JasperMobile.Report.Event.reportCompleted";
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment addListener:self
                          forEventId:reportCompletedListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(reportCompletedListenerId);
                                JMLog(@"parameters: %@", params);
                                if (!weakSelf) {
                                    return;
                                }
                                // TODO: move into separate method
                                NSInteger countOfPages = ((NSNumber *)params[@"pages"]).integerValue;
                                [weakSelf.report updateCountOfPages:countOfPages];
                            }];
    NSString *changePagesStateListenerId = @"JasperMobile.Report.Event.changePagesState";
    [self.webEnvironment addListener:self
                          forEventId:changePagesStateListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(changePagesStateListenerId);
                                JMLog(@"parameters: %@", params);
                                if (!weakSelf) {
                                    return;
                                }
                                NSString *locationString = params[@"page"];
                                [weakSelf.report updateCurrentPage:locationString.integerValue];
                            }];
    NSString *bookmarsReadyListenerId = @"JasperMobile.Report.Event.bookmarksReady";
    [self.webEnvironment addListener:self
                          forEventId:bookmarsReadyListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(bookmarsReadyListenerId);
                                JMLog(@"parameters: %@", params);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    // TODO: handle error
                                } else {
                                    if (params[@"bookmarks"]) {
                                        NSArray *bookmarks = [weakSelf mapBookmarksFromParams:params[@"bookmarks"]];
                                        weakSelf.report.bookmarks = bookmarks;
                                    } else {
                                        // empty array;
                                    }
                                }
                            }];
    NSString *partsReadyListenerId = @"JasperMobile.Report.Event.reportPartsReady";
    [self.webEnvironment addListener:self
                          forEventId:partsReadyListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(partsReadyListenerId);
                                JMLog(@"parameters: %@", params);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    // TODO: handle error
                                } else {
                                    if (params[@"parts"]) {
                                        NSArray *parts = [weakSelf mapReportPartsFromParams:params[@"parts"]];
                                        weakSelf.report.parts = parts;
                                    } else {
                                        // empty array;
                                    }
                                }
                            }];
    NSString *mulitpageReportListenerId = @"JasperMobile.Report.Event.MultipageReport";
    [self.webEnvironment addListener:self
                          forEventId:mulitpageReportListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(mulitpageReportListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    // TODO: handle error
                                } else {
                                    [weakSelf.report updateIsMultiPageReport:YES];
                                }
                            }];

    // Hyperlinks

    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.ReportExecution";
    [self.webEnvironment addListener:self
                          forEventId:reportExecutionLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(reportExecutionLinkOptionListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    if (error.code == JMJavascriptRequestErrorTypeOther) {
                                        NSString *javascriptErrorCode = error.userInfo[JMJavascriptRequestExecutorErrorCodeKey];
                                        if (javascriptErrorCode && [javascriptErrorCode isEqualToString:@"hyperlink.not.support.error"]) {
                                            if ([weakSelf.delegate respondsToSelector:@selector(reportLoaderDidReceiveEventWithUnsupportedHyperlink:)]) {
                                                [weakSelf.delegate reportLoaderDidReceiveEventWithUnsupportedHyperlink:weakSelf];
                                            }
                                        }
                                    }
                                } else {
                                    [weakSelf handleRunReportWithParameters:params];
                                }
                            }];
    NSString *localPageLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.LocalPage";
    [self.webEnvironment addListener:self
                          forEventId:localPageLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(localPageLinkOptionListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                NSString *locationString = params[@"destination"];
                                [weakSelf.report updateCurrentPage:locationString.integerValue];
                            }];
    NSString *localAnchorLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.LocalAnchor";
    [self.webEnvironment addListener:self
                          forEventId:localAnchorLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(localAnchorLinkOptionListenerId);
                            }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.Reference";
    [self.webEnvironment addListener:self
                          forEventId:referenceLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(referenceLinkOptionListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                NSString *locationString = params[@"destination"];
                                if (locationString) {
                                    if ([weakSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
                                        JMHyperlink *hyperlink = [JMHyperlink new];
                                        hyperlink.type = JMHyperlinkTypeReference;
                                        hyperlink.href = locationString;
                                        [weakSelf.delegate reportLoader:weakSelf didReceiveEventWithHyperlink:hyperlink];
                                    }
                                }
                            }];
    NSString *remoteAnchorListenerId = @"JasperMobile.VIS.Report.Event.Link.RemoteAnchor";
    [self.webEnvironment addListener:self
                          forEventId:remoteAnchorListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(remoteAnchorListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                JMLog(@"parameters: %@", params);
                                NSDictionary *link = params[@"link"];
                                if (link && [link isKindOfClass:[NSDictionary class]]) {
                                    NSString *href = link[@"href"];
                                    if (href) {
                                        NSString *prefix = [href substringWithRange:NSMakeRange(0, 1)];
                                        if ([prefix isEqualToString:@"."]) {
                                            href = [href stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
                                        }
                                        NSString *fullURLString = [weakSelf.restClient.serverProfile.serverUrl stringByAppendingString:href];
                                        JMLog(@"full url string: %@", fullURLString);
                                        if ([weakSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
                                            JMHyperlink *hyperlink = [JMHyperlink new];
                                            hyperlink.type = JMHyperlinkTypeRemoteAnchor;
                                            hyperlink.href = fullURLString;
                                            [weakSelf.delegate reportLoader:weakSelf didReceiveEventWithHyperlink:hyperlink];
                                        }
                                    }
                                }
                            }];
    NSString *remotePageListenerId = @"JasperMobile.VIS.Report.Event.Link.RemotePage";
    [self.webEnvironment addListener:self
                          forEventId:remotePageListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(remotePageListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                JMLog(@"parameters: %@", params);
                                NSDictionary *link = params[@"link"];
                                if (link && [link isKindOfClass:[NSDictionary class]]) {
                                    NSString *href = link[@"href"];
                                    if (href) {
                                        NSString *prefix = [href substringWithRange:NSMakeRange(0, 1)];
                                        if ([prefix isEqualToString:@"."]) {
                                            href = [href stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
                                        }
                                        NSString *fullURLString = [weakSelf.restClient.serverProfile.serverUrl stringByAppendingString:href];
                                        JMLog(@"full url string: %@", fullURLString);
                                        if ([weakSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
                                            JMHyperlink *hyperlink = [JMHyperlink new];
                                            hyperlink.type = JMHyperlinkTypeRemotePage;
                                            hyperlink.href = fullURLString;
                                            [weakSelf.delegate reportLoader:weakSelf didReceiveEventWithHyperlink:hyperlink];
                                        }
                                    }
                                }
                            }];
}

- (void)removeListenersForVisualizeEvents
{
    [self.webEnvironment removeListener:self];
}

#pragma mark - Helpers
- (NSDictionary *)configureParameters:(NSArray <JSReportParameter *>*)parameters
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSMutableDictionary *runParams = [@{} mutableCopy];
    for (JSReportParameter *parameter in parameters) {
        runParams[parameter.name] = parameter.value;
    }
    return runParams;
}

#pragma mark - Hyperlinks handlers
- (void)handleRunReportWithParameters:(NSDictionary *)parameters
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMLog(@"parameters: %@", parameters);
    NSDictionary *data = parameters[@"data"];
    if (!data) {
        return;
    }

    NSString *reportPath = data[@"resource"];
    if (reportPath) {
        if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
            JMHyperlink *hyperlink = [JMHyperlink hyperlinkWithHref:reportPath withRawData:data[@"params"]];
            [self.delegate reportLoader:self didReceiveEventWithHyperlink:hyperlink];
        }
    }
}

#pragma mark - Bookmarks Handler
- (NSArray *)mapBookmarksFromParams:(NSArray *__nonnull)params
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
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
        JSReportBookmark *bookmark = [JSReportBookmark bookmarkWithAnchor:anchor page:page];
        bookmark.bookmarks = nestedBookmarks;
        [bookmarks addObject:bookmark];
    }

    return bookmarks;
}

#pragma mark - Handle Report Parts (Workbooks)
- (NSArray *)mapReportPartsFromParams:(NSArray *__nonnull)params
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(params != nil, @"parameters is nil");
    NSAssert([params isKindOfClass:[NSArray class]], @"Parameters should be NSArray class");

    NSMutableArray *parts = [NSMutableArray new];

    for (NSDictionary *reportPartData in params) {
        // TODO: how handle empty fields?
        NSString *title = reportPartData[@"name"];
        NSNumber *page = reportPartData[@"page"];
        JSReportPart *part = [[JSReportPart alloc] initWithTitle:title page:page];
        [parts addObject:part];
    }

    return parts;
}

#pragma mark - Errors handling
- (NSError *)loaderErrorFromBridgeError:(NSError *)error
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JSReportLoaderErrorType errorCode = JSReportLoaderErrorTypeUndefined;
    switch(error.code) {
        case JMJavascriptRequestErrorTypeAuth: {
            errorCode = JSReportLoaderErrorTypeAuthentification;
            break;
        }
        case JMJavascriptRequestErrorTypeOther: {
            errorCode = JSReportLoaderErrorTypeUndefined;
            break;
        }
        case JMJavascriptRequestErrorTypeWindow: {
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
