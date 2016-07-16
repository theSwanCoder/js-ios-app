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
        _restClient = restClient;
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
                                            strongSelf.state = JSReportLoaderStateLoading;
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

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.cancel"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"canceling report was finished");
            [self.webEnvironment removeAllListeners];
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

    self.state = JSReportLoaderStateLoading;

    JSReportLoaderCompletionBlock heapBlock = [completion copy];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment prepareWithCompletion:^(BOOL isReady, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JSReportLoaderStateCancel) {
            return;
        }
        if (isReady) {
            [strongSelf freshLoadReportWithDestination:destination
                                            parameters:initialParameters
                                            completion:heapBlock];
        } else {
            strongSelf.state = JSReportLoaderStateFailed;
            heapBlock(NO, [strongSelf loaderErrorFromBridgeError:error]);
        }
    }];
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
            [self.webEnvironment removeAllListeners];
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
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    // Life Cycle

    NSString *reportCompletedListenerId = @"JasperMobile.Report.Event.reportCompleted";
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment addListenerWithId:reportCompletedListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(reportCompletedListenerId);
        JMLog(@"parameters: %@", parameters);
        __typeof(self) strongSelf = weakSelf;
        // TODO: move into separate method
        NSInteger countOfPages = ((NSNumber *)parameters[@"pages"]).integerValue;
        [strongSelf.report updateCountOfPages:countOfPages];
    }];
    NSString *changePagesStateListenerId = @"JasperMobile.Report.Event.changePagesState";
    [self.webEnvironment addListenerWithId:changePagesStateListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(changePagesStateListenerId);
        JMLog(@"parameters: %@", parameters);
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = parameters[@"page"];
        [strongSelf.report updateCurrentPage:locationString.integerValue];
    }];
    NSString *bookmarsReadyListenerId = @"JasperMobile.Report.Event.bookmarksReady";
    [self.webEnvironment addListenerWithId:bookmarsReadyListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(bookmarsReadyListenerId);
        JMLog(@"parameters: %@", parameters);
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
        JMLog(@"parameters: %@", parameters);
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

    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.ReportExecution";
    [self.webEnvironment addListenerWithId:reportExecutionLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(reportExecutionLinkOptionListenerId);
        if (error) {
            if (error.code == JMJavascriptNativeBridgeErrorTypeOther) {
                NSString *javascriptErrorCode = error.userInfo[JMJavascriptNativeBridgeErrorCodeKey];
                if (javascriptErrorCode && [javascriptErrorCode isEqualToString:@"hyperlink.not.support.error"]) {
                    if ([self.delegate respondsToSelector:@selector(reportLoaderDidReceiveEventWithUnsupportedHyperlink:)]) {
                        [self.delegate reportLoaderDidReceiveEventWithUnsupportedHyperlink:self];
                    }
                }
            }
        } else {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf handleRunReportWithParameters:parameters];
        }
    }];
    NSString *localPageLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.LocalPage";
    [self.webEnvironment addListenerWithId:localPageLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(localPageLinkOptionListenerId);
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = parameters[@"destination"];
        [strongSelf.report updateCurrentPage:locationString.integerValue];
    }];
    NSString *localAnchorLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.LocalAnchor";
    [self.webEnvironment addListenerWithId:localAnchorLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(localAnchorLinkOptionListenerId);
    }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.VIS.Report.Event.Link.Reference";
    [self.webEnvironment addListenerWithId:referenceLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(referenceLinkOptionListenerId);
        __typeof(self) strongSelf = weakSelf;
        NSString *locationString = parameters[@"destination"];
        if (locationString) {
            if ([strongSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
                JMHyperlink *hyperlink = [JMHyperlink new];
                hyperlink.type = JMHyperlinkTypeReference;
                hyperlink.href = locationString;
                [strongSelf.delegate reportLoader:strongSelf didReceiveEventWithHyperlink:hyperlink];
            }
        }
    }];
    NSString *remoteAnchorListenerId = @"JasperMobile.VIS.Report.Event.Link.RemoteAnchor";
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
                if ([strongSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
                    JMHyperlink *hyperlink = [JMHyperlink new];
                    hyperlink.type = JMHyperlinkTypeRemoteAnchor;
                    hyperlink.href = fullURLString;
                    [strongSelf.delegate reportLoader:strongSelf didReceiveEventWithHyperlink:hyperlink];
                }
            }
        }
    }];
    NSString *remotePageListenerId = @"JasperMobile.VIS.Report.Event.Link.RemotePage";
    [self.webEnvironment addListenerWithId:remotePageListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(remotePageListenerId);
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
                if ([strongSelf.delegate respondsToSelector:@selector(reportLoader:didReceiveEventWithHyperlink:)]) {
                    JMHyperlink *hyperlink = [JMHyperlink new];
                    hyperlink.type = JMHyperlinkTypeRemotePage;
                    hyperlink.href = fullURLString;
                    [strongSelf.delegate reportLoader:strongSelf didReceiveEventWithHyperlink:hyperlink];
                }
            }
        }
    }];
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
