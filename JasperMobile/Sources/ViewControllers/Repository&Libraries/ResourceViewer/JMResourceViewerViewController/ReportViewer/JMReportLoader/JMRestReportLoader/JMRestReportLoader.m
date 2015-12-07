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
#import "NSObject+Additions.h"
#import "JMReportViewerVC.h"
#import "JMJavascriptNativeBridgeProtocol.h"

static NSInteger const kJMReportViewerStatusCheckingInterval = 1.f;
static NSString *const kJMRestStatusReady = @"ready";
static NSString *const kJMRestStatusCanceled = @"canceled";


@interface JMRestReportLoader()
@property (nonatomic, weak, readwrite) JMReport *report;
@property (nonatomic, assign, readwrite) BOOL isReportInLoadingProcess;

// callbacks
@property (nonatomic, copy) void(^loadPageCompletionBlock)(BOOL success, NSError *error);
//
@property (nonatomic, assign) BOOL isReportExecutingStatusReady;
//@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSMutableDictionary *exportIdsDictionary;
@property (nonatomic, assign) JMReportViewerOutputResourceType outputResourceType;
@property (nonatomic, strong) NSTimer *statusCheckingTimer;
@end

@implementation JMRestReportLoader
@synthesize bridge = _bridge, delegate = _delegate;

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JMReport *)report
{
    self = [super init];
    if (self) {
        _report = report;
        _exportIdsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)loaderWithReport:(JMReport *)report
{
    return [[self alloc] initWithReport:report];
}

#pragma mark - Custom accessors
- (void)setBridge:(id<JMJavascriptNativeBridgeProtocol>)bridge
{
    _bridge = bridge;
//    _bridge.delegate = self;
}

#pragma mark - Public API
- (void)runReportWithPage:(NSInteger)page completion:(void(^)(BOOL success, NSError *error))completionBlock;
{
    [self.report restoreDefaultState];

    self.loadPageCompletionBlock = completionBlock;
    

    [self.report updateCurrentPage:page];
    
    // restore default state of loader
    self.exportIdsDictionary = [@{} mutableCopy];
    self.isReportInLoadingProcess = YES;
    self.outputResourceType = JMReportViewerOutputResourceType_None;
    
    [self runReportExecution];
}

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(void(^)(BOOL success, NSError *error))completionBlock
{
    self.loadPageCompletionBlock = completionBlock;
    [self.report updateCurrentPage:pageNumber];
    [self startExportExecutionForPage:pageNumber];
}

- (void)cancel
{
    [self.restClient cancelAllRequests];
    [self.statusCheckingTimer invalidate];
    self.loadPageCompletionBlock = nil;
    if (!self.isReportExecutingStatusReady && self.report.requestId) {
        [self.restClient cancelReportExecution:self.report.requestId completionBlock:nil];
    }
}

- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [self.bridge reset];
    [self runReportWithPage:1 completion:completion];
}

- (void)applyReportParametersWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    [self runReportWithPage:1 completion:completion];
}

- (void)destroy
{
    [self.bridge reset];
}

#pragma mark - Private API

- (void) runReportExecution
{
    [self.restClient runReportExecution:self.report.reportURI
                                  async:YES
                           outputFormat:kJS_CONTENT_TYPE_HTML
                            interactive:[self isInteractive]
                              freshData:YES
                       saveDataSnapshot:NO
                       ignorePagination:NO
                         transformerKey:nil
                                  pages:nil
                      attachmentsPrefix:kJS_REST_EXPORT_EXECUTION_ATTACHMENTS_PREFIX_URI
                             parameters:self.report.reportParameters
                        completionBlock:^(JSOperationResult *result) {
                            
                                 if (result.error) {
                                     self.loadPageCompletionBlock(NO, result.error);
                                 } else {
                                     JSReportExecutionResponse *response = [result.objects firstObject];
                                     NSString *requestId = response.requestId;
                                     
                                     if (requestId) {
                                         [self.report updateRequestId:requestId];
                                         
                                         self.isReportExecutingStatusReady = [response.status.status isEqualToString:kJMRestStatusReady];
                                         
                                         if (self.isReportExecutingStatusReady) {
                                             NSInteger countOfPages = response.totalPages.integerValue;
                                             [self.report updateCountOfPages:countOfPages];
                                         } else {
                                             // only for updating toolbar pages
                                             [self startStatusChecking];
                                         }
                                         
                                         BOOL isStatusCanceled = [response.status.status isEqualToString:kJMRestStatusCanceled];
                                         if (!isStatusCanceled) {
                                             if (self.report.countOfPages > 0) {
                                                 [self startExportExecutionForPage:self.report.currentPage];
                                             } else {
                                                 [self handleEmptyReport];
                                             }
                                         }
                                         
                                     } else {
                                         if (self.loadPageCompletionBlock) {
                                             NSInteger code = JMReportLoaderErrorTypeUndefined;
                                             NSDictionary *userInfo = @{NSLocalizedDescriptionKey : JMCustomLocalizedString(@"error.readingresponse.dialog.msg", nil) };
                                             NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                                                                  code:code
                                                                              userInfo:userInfo];
                                             self.loadPageCompletionBlock(NO, error);
                                         }
                                     }
                                 }
                             }];
}

- (void) startExportExecutionForPage:(NSInteger)page
{
    NSDictionary *cachedPages = [self.report cachedReportPages];
    NSString *HTMLString = cachedPages[@(page)];
    if (HTMLString && self.loadPageCompletionBlock) { // show cached page
        JMLog(@"load cached page");
        [self.report updateHTMLString:HTMLString baseURLSring:self.report.baseURLString];
        self.report.isReportAlreadyLoaded = (HTMLString.length > 0);

        [self startLoadReportHTML];
        self.loadPageCompletionBlock(YES, nil);
    } else { // export page
        NSString *exportID = self.exportIdsDictionary[@(page)];
        if (exportID) {
            if (exportID.length) {
                [self loadOutputResourcesForPage:page];
            }
        } else if (page <= self.report.countOfPages) {
            [self.restClient runExportExecution:self.report.requestId
                                   outputFormat:kJS_CONTENT_TYPE_HTML
                                          pages:@(page).stringValue
                              attachmentsPrefix:kJS_REST_EXPORT_EXECUTION_ATTACHMENTS_PREFIX_URI
                                completionBlock:^(JSOperationResult *result) {
                                    
                                    if (result.error) {
                                        self.loadPageCompletionBlock(NO, result.error);
                                    } else {
                                        JSExportExecutionResponse *export = [result.objects firstObject];
                                        
                                        if (export.uuid.length) {
                                            self.exportIdsDictionary[@(page)] = export.uuid;
                                            [self loadOutputResourcesForPage:page];
                                        } else {
                                            if (self.loadPageCompletionBlock) {
                                                NSInteger code = JMReportLoaderErrorTypeUndefined;
                                                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : JMCustomLocalizedString(@"error.readingresponse.dialog.msg", nil) };
                                                NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                                                                     code:code
                                                                                 userInfo:userInfo];
                                                self.loadPageCompletionBlock(NO, error);
                                            }
                                        }
                                    }
                                }];
        }
    }
}

- (void)loadOutputResourcesForPage:(NSInteger)page
{
    if (page == self.report.currentPage) {
        self.outputResourceType = JMReportViewerOutputResourceType_LoadingNow;
    }
    NSString *exportID = self.exportIdsDictionary[@(page)];
    
    // Fix for JRS version smaller 5.6.0
    NSString *fullExportID = exportID;
    if (self.restClient.serverInfo.versionAsFloat < kJS_SERVER_VERSION_CODE_EMERALD_5_6_0) {
        fullExportID = [NSString stringWithFormat:@"%@;pages=%@", exportID, @(page)];
    }
    
    [self.restClient loadReportOutput:self.report.requestId
                         exportOutput:fullExportID
                        loadForSaving:NO
                                 path:nil
                      completionBlock:^(JSOperationResult *result) {
                          
                          if (result.error && result.error.code != JSOtherErrorCode) {
                              [self handleErrorWithOperationResult:result forPage:page];
                          } else {
                              
                              if ([result.MIMEType isEqualToString:[JSUtils usedMimeType]]) {
                                  [self handleErrorWithOperationResult:result forPage:page];
                              } else {
                                  self.outputResourceType = [result.allHeaderFields[@"output-final"] boolValue]? JMReportViewerOutputResourceType_Final : JMReportViewerOutputResourceType_NotFinal;
                                  
                                  if (self.outputResourceType == JMReportViewerOutputResourceType_Final) {
                                      [self.report cacheHTMLString:result.bodyAsString forPageNumber:page];
                                  }
                                  
                                  if (page == self.report.currentPage) { // show current page
                                      self.isReportInLoadingProcess = NO;
                                      if (self.loadPageCompletionBlock) {
                                          [self.report updateHTMLString:result.bodyAsString
                                                           baseURLSring:self.restClient.serverProfile.serverUrl];
                                          self.report.isReportAlreadyLoaded = (result.bodyAsString.length > 0);
                                          [self startLoadReportHTML];
                                          self.loadPageCompletionBlock(YES, nil);
                                      }
                                  }
                                  
                                  // Try to load second page
                                  if (self.report.currentPage == 1) {
                                      if ([self.exportIdsDictionary count] == 1) {
                                          [self startExportExecutionForPage:2];
                                      }
                                      
                                      if (page == 2 && [self.exportIdsDictionary count] == 2) {
                                          [self.report updateIsMultiPageReport:YES];
                                      }
                                  }
                              }
                          }
                      }];
}

- (void)startLoadReportHTML
{
    NSString *jsMobilePath = [[NSBundle mainBundle] pathForResource:@"jaspermobile" ofType:@"js"];
    NSError *error;
    NSString *jsMobile = [NSString stringWithContentsOfFile:jsMobilePath encoding:NSUTF8StringEncoding error:&error];
    CGFloat initialZoom = 2;
    if ([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) {
        initialZoom = 1;
    }
    jsMobile = [jsMobile stringByReplacingOccurrencesOfString:@"INITIAL_ZOOM" withString:@(initialZoom).stringValue];
    [self.bridge injectJSInitCode:jsMobile];
    [self.bridge startLoadHTMLString:self.report.HTMLString
                             baseURL:[NSURL URLWithString:self.report.baseURLString]];
}

#pragma mark - Check status

- (void)startStatusChecking
{
    if (!self.isReportExecutingStatusReady) {
        self.statusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportViewerStatusCheckingInterval
                                                                    target:self
                                                                  selector:@selector(makeStatusChecking)
                                                                  userInfo:nil
                                                                   repeats:YES];
    }
}

- (void)stopStatusChecking
{
    BOOL isNotFinal = self.outputResourceType == JMReportViewerOutputResourceType_NotFinal;
    BOOL isLoadingNow = self.outputResourceType == JMReportViewerOutputResourceType_LoadingNow;
    if (isNotFinal && !isLoadingNow) {
        [self startExportExecutionForPage:self.report.currentPage];
    }
    
    [self.restClient reportExecutionMetadataForRequestId:self.report.requestId
                                         completionBlock:^(JSOperationResult *result) {
        if (!result.error) {
            JSReportExecutionResponse *response = [result.objects firstObject];
            NSInteger countOfPages = response.totalPages.integerValue;
            if (countOfPages > 0) {
                [self.report updateCountOfPages:countOfPages];
            } else {
                [self handleEmptyReport];
            }
        }
    }];
}

- (void) makeStatusChecking
{
    [self.restClient reportExecutionStatusForRequestId:self.report.requestId
                                       completionBlock:^(JSOperationResult *result) {
        if (!result.error) {
            JSExecutionStatus *status = [result.objects firstObject];
            if (!self.isReportExecutingStatusReady) {
                self.isReportExecutingStatusReady = [status.status isEqualToString:kJMRestStatusReady];
                
                if (self.isReportExecutingStatusReady) {
                    [self stopStatusChecking];
                    
                    if (self.statusCheckingTimer.valid) {
                        [self.statusCheckingTimer invalidate];
                    }
                }
            }
        }
    }];
}

#pragma mark - Handels
- (void)handleEmptyReport
{
    NSInteger code = JMReportLoaderErrorTypeEmtpyReport;
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : JMCustomLocalizedString(@"report.viewer.emptyreport.title", nil)};
    NSError *error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                         code:code
                                     userInfo:userInfo];
    self.loadPageCompletionBlock(NO, error);
}

#pragma mark - Helpers
- (BOOL)isReportEmpty
{
    return (self.isReportExecutingStatusReady && self.report.countOfPages == 0);
}

- (BOOL)isInteractive
{
    CGFloat currentVersion = self.restClient.serverInfo.versionAsFloat;
    CGFloat currentVersion_const = kJS_SERVER_VERSION_CODE_EMERALD_5_6_0;
    BOOL interactive = (currentVersion > currentVersion_const || currentVersion < currentVersion_const);
    return interactive;
}

#pragma mark - Request delegates

- (void)handleErrorWithOperationResult:(JSOperationResult *)result forPage:(NSInteger)page
{
    if (page == self.report.currentPage) {
        if (result.error.code == JSNetworkErrorCode) {
            // TODO: need investigate error handling
            [self.restClient deleteCookies];
        } else {
            self.loadPageCompletionBlock(NO, result.error);
        }
    } else {
        JSErrorDescriptor *error = [result.objects firstObject];
        BOOL isIllegalParameter = [error.errorCode isEqualToString:@"illegal.parameter.value.error"];
        BOOL isPagesOutOfRange = [error.errorCode isEqualToString:@"export.pages.out.of.range"];
        BOOL isExportFailed = [error.errorCode isEqualToString:@"export.failed"];
        if (isIllegalParameter || isPagesOutOfRange || isExportFailed) {
            [self.report updateCountOfPages:page - 1];
        }
    }
}

@end
