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

#import "JMReportViewer.h"
#import "JMRequestDelegate.h"
#import "JMCancelRequestPopup.h"
#import "UIViewController+fetchInputControls.h"
#import "UIAlertView+Additions.h"

typedef NS_ENUM(NSInteger, JMReportViewerOutputResourceType) {
    JMReportViewerOutputResourceType_None = 0,
    JMReportViewerOutputResourceType_LoadingNow,
    JMReportViewerOutputResourceType_NotFinal,
    JMReportViewerOutputResourceType_Final,
    JMReportViewerOutputResourceType_AlreadyLoaded = JMReportViewerOutputResourceType_NotFinal | JMReportViewerOutputResourceType_Final
};

#define kJMReportViewerStatusCheckingInterval       1.f

NSString * const kJMRestStatusReady = @"ready";

@interface JMReportViewer() <UIAlertViewDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, assign) BOOL reportExequtingStatusIsReady;

@property (nonatomic, strong) NSMutableDictionary *exportIdsDictionary;
@property (nonatomic, assign) JMReportViewerOutputResourceType outputResourceType;

@property (nonatomic, strong) NSTimer *statusCheckingTimer;

@property (nonatomic, strong) NSUndoManager *icUndoManager;

@property (nonatomic, readwrite) NSInteger countOfPages;
@property (nonatomic, readwrite) BOOL multiPageReport;

@property (nonatomic, copy) JSRequestFinishedBlock errorExecutionBlock;
@property (nonatomic, assign) BOOL isReportRunSuccessful;
@end

@implementation JMReportViewer
objection_requires(@"resourceClient", @"reportClient")

@synthesize reportClient    = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Initialization

- (instancetype)initWithResourceLookup:(JSResourceLookup *)resource
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        self.icUndoManager = [NSUndoManager new];
        self.resourceLookup = resource;
        self.errorExecutionBlock = @weakself(^(JSOperationResult *result)){
            NSString *title = nil;
            NSString *message = nil;
            if ([result.objects count] && [[result.objects objectAtIndex:0] isKindOfClass:[JSErrorDescriptor class]]){
                JSErrorDescriptor *error = [result.objects objectAtIndex:0];
                title = error.errorCode;
                message = error.message;
            } else {
                title = result.error.domain;
                message = result.error.localizedDescription;
            }
            [[UIAlertView alertWithTitle:title message:message completion:@weakself(^(UIAlertView *alertView, NSInteger buttonIndex)) {
                [self cancelReport];
            } @weakselfend cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.ok", nil) otherButtonTitles:nil] show];
        }@weakselfend;
        
        _isReportRunSuccessful = NO;
    }
    return self;
}

#pragma mark - 
#pragma mark - Properties
- (void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage != _currentPage) {
        _currentPage = currentPage;
        if (self.currentPage) {
            [self runExportExecutionForPage:_currentPage];
        }
        [self.delegate reportViewerDidChangedPagination:self];
    }
}

- (void)setCountOfPages:(NSInteger)countOfPages
{
    if (countOfPages != _countOfPages) {
        _countOfPages = countOfPages;
        if (self.currentPage > _countOfPages) {
            self.currentPage = _countOfPages;
        }
        _multiPageReport = (self.countOfPages > 1) && (self.countOfPages != kJMCountOfPagesUnknown);
        [self.delegate reportViewerDidChangedPagination:self];
        if ([self reportIsEmpty]) {
            [self showAlertEmtpyReport];
        }
    }
}

- (void)setMultiPageReport:(BOOL)multiPageReport
{
    if (_multiPageReport != multiPageReport) {
        _multiPageReport = multiPageReport;
        [self.delegate reportViewerDidChangedPagination:self];
    }
}

- (void)setInputControls:(NSMutableArray *)inputControls
{
    if (self.inputControls != inputControls) {
        _inputControls = inputControls;
    }
}

- (void) resetReportViewer
{
    if (self.requestId && ![self reportIsEmpty]) {
        [self.icUndoManager removeAllActionsWithTarget:self];
        [[self.icUndoManager prepareWithInvocationTarget:self] setValues:self.requestId
                                                               exportIds:self.exportIdsDictionary
                                                           inputControls:self.inputControls
                                                            countOfPages:self.countOfPages
                                                             currentPage:self.currentPage
                                                           statusIsReady:self.reportExequtingStatusIsReady
                                                      outputResourceType:self.outputResourceType];
        [self.icUndoManager setActionName:@"ResetChanges"];
        self.isReportRunSuccessful = YES;
    }
    
    [self setValues:nil
          exportIds:[NSMutableDictionary dictionary]
      inputControls:self.inputControls
       countOfPages:kJMCountOfPagesUnknown
        currentPage:1 statusIsReady:NO
 outputResourceType:JMReportViewerOutputResourceType_None];
}

- (void) setValues:(NSString *)requestID
         exportIds:(NSMutableDictionary *)exportIds
     inputControls:(NSMutableArray *)inputControls
      countOfPages:(NSInteger)countOfPages
       currentPage:(NSInteger)currentPage
     statusIsReady:(BOOL)status
outputResourceType:(JMReportViewerOutputResourceType)outputResourceType
{
    self.outputResourceType = outputResourceType;
    self.exportIdsDictionary = exportIds;
    self.reportExequtingStatusIsReady = status;
    self.requestId = requestID;
    self.inputControls = inputControls;
    self.countOfPages = countOfPages;
    self.currentPage = currentPage;
}

- (void) runReportExecution
{
    [JMCancelRequestPopup presentWithMessage:@"status.loading" restClient:self.reportClient cancelBlock:@weakself(^(void)) {
        [self cancelReport];
    } @weakselfend];

    [self resetReportViewer];
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
        JSReportExecutionResponse *reportExecution = [result.objects objectAtIndex:0];
        self.requestId = reportExecution.requestId;
        self.reportExequtingStatusIsReady = [reportExecution.status.status isEqualToString:kJMRestStatusReady];
        if (self.reportExequtingStatusIsReady) {
            self.countOfPages = [reportExecution.totalPages integerValue];
        } else {
            [self startStatusChecking];
        }
        if (![self reportIsEmpty]) {
            [self runExportExecutionForPage:self.currentPage];
        }
    } @weakselfend
    errorBlock:self.errorExecutionBlock
    viewControllerToDismiss:(!self.requestId) ? self.delegate : nil];
    
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in self.inputControls) {
        [parameters addObject:[[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid value:inputControlDescriptor.selectedValues]];
    }
    
    BOOL interactive = !((self.reportClient.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) &&
                        (self.reportClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_0_0));
    
    NSString *attachemntPreffix = [JSConstants sharedInstance].REST_EXPORT_EXECUTION_ATTACHMENTS_PREFIX_URI;
    
    // Fix for JRS version smaller 5.6.0
    if (self.reportClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) {
        attachemntPreffix = nil;
    }

    [self.reportClient runReportExecution:self.resourceLookup.uri async:YES outputFormat:[JSConstants sharedInstance].CONTENT_TYPE_HTML
                              interactive:interactive freshData:YES saveDataSnapshot:NO ignorePagination:NO transformerKey:nil
                                    pages:nil attachmentsPrefix:attachemntPreffix parameters:parameters delegate:requestDelegate];
}

- (void) runExportExecutionForPage:(NSInteger)page
{
    if (self.requestId) {
        NSString *exportID = [self.exportIdsDictionary objectForKey:@(page)];
        if (exportID) {
            if (exportID.length) {
                [self loadOutputResourcesForPage:page];
            }
        } else if (page <= self.countOfPages) {
            if (page == self.currentPage) {
                [JMCancelRequestPopup presentWithMessage:@"status.loading" restClient:self.reportClient cancelBlock:@weakself(^(void)) {
                    [self cancelReport];
                } @weakselfend];
            } else {
                [self.delegate reportViewerShouldDisplayActivityIndicator:self];
            }

            JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
                JSExportExecutionResponse *export = [result.objects objectAtIndex:0];
                [self.exportIdsDictionary setObject:export.uuid forKey:@(page)];
                [self loadOutputResourcesForPage:page];
            } @weakselfend
            errorBlock:self.errorExecutionBlock
            viewControllerToDismiss:nil];
            
            NSString *pagesString = [NSString stringWithFormat:@"%zd", page];
            NSString *attachemntPreffix = [JSConstants sharedInstance].REST_EXPORT_EXECUTION_ATTACHMENTS_PREFIX_URI;

            // Fix for JRS version smaller 5.6.0
            if (self.reportClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) {
                attachemntPreffix = nil;
            }
            [self.reportClient runExportExecution:self.requestId outputFormat:[JSConstants sharedInstance].CONTENT_TYPE_HTML pages:pagesString
                                attachmentsPrefix:attachemntPreffix delegate:requestDelegate];
            [self.exportIdsDictionary setObject:@"" forKey:@(page)];
        }
    }
}

- (void) loadOutputResourcesForPage:(NSInteger)page
{
    NSString *exportID = [self.exportIdsDictionary objectForKey:@(page)];
    if (page == self.currentPage) {
        self.outputResourceType = JMReportViewerOutputResourceType_LoadingNow;
    }

    // Fix for JRS version smaller 5.6.0
    NSString *fullExportID = exportID;
    if (self.reportClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) {
        fullExportID = [NSString stringWithFormat:@"%@;pages=%zd", exportID, page];
    }
    
    void (^errorHandlerBlock)(NSInteger page, JSOperationResult *result) = ^(NSInteger page, JSOperationResult *result){
        JSErrorDescriptor *error = [result.objects objectAtIndex:0];
        if (page == self.currentPage) {
            self.errorExecutionBlock(result);
        } else {
            if ([error.errorCode isEqualToString:@"illegal.parameter.value.error"] ||
                [error.errorCode isEqualToString:@"export.pages.out.of.range"] ||
                [error.errorCode isEqualToString:@"export.failed"]) {
                self.countOfPages = page - 1;
            }
        }
    };
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
        if ([result.MIMEType isEqualToString:[JSConstants sharedInstance].REST_SDK_MIMETYPE_USED]) {
            errorHandlerBlock(page, result);
        } else {
            if (page == self.currentPage) {
                self.outputResourceType = [result.allHeaderFields objectForKey:@"output-final"] ? JMReportViewerOutputResourceType_Final : JMReportViewerOutputResourceType_NotFinal;
                [self.delegate reportViewer:self loadHTMLString:result.bodyAsString baseURL:self.reportClient.serverProfile.serverUrl];
                [self runExportExecutionForPage:page + 1];
            }

            if (page > 1) {
                self.multiPageReport = YES;
            }
        }
    } @weakselfend
    errorBlock:@weakself(^(JSOperationResult *result)) {
        errorHandlerBlock(page, result);
    }@weakselfend
    viewControllerToDismiss: nil
    showAlerts:NO];
    
    [self.reportClient loadReportOutput:self.requestId exportOutput:fullExportID loadForSaving:NO path:nil delegate:requestDelegate];
}

- (void)startStatusChecking
{
    self.statusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportViewerStatusCheckingInterval target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
}

- (void)cancelStatusChecking
{
    [self.statusCheckingTimer invalidate];
    if (self.outputResourceType == JMReportViewerOutputResourceType_NotFinal && self.outputResourceType != JMReportViewerOutputResourceType_LoadingNow) {
        [self runExportExecutionForPage:self.currentPage];
    }
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
        JSReportExecutionResponse *reportDetails = [result.objects objectAtIndex:0];
        self.countOfPages = [reportDetails.totalPages integerValue];
    } @weakselfend
    errorBlock:nil
    viewControllerToDismiss: nil];
    
    [self.reportClient getReportExecutionMetadata:self.requestId delegate:requestDelegate];
}

- (void) checkStatus
{
    if (!self.reportExequtingStatusIsReady) {
        JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
            JSExecutionStatus *status = [result.objects objectAtIndex:0];
            self.reportExequtingStatusIsReady = [status.status isEqualToString:kJMRestStatusReady];
            if (self.reportExequtingStatusIsReady) {
                [self cancelStatusChecking];
            }
        } @weakselfend
        errorBlock:nil
        viewControllerToDismiss: nil];
        [self.reportClient getReportExecutionStatus:self.requestId delegate:requestDelegate];
    } else {
        [self cancelStatusChecking];
    }
}

- (void) cancelReport
{
    [self.statusCheckingTimer invalidate];
    if (!self.reportExequtingStatusIsReady) {
        [self.reportClient cancelReportExecution:self.requestId delegate:nil];
    }
    [self.delegate reportViewerReportDidCanceled:self];
}

- (BOOL)reportIsEmpty
{
    return (self.reportExequtingStatusIsReady && self.countOfPages == 0);
}

- (void)showAlertEmtpyReport
{
    void(^alertCompletion)(UIAlertView *alertView, NSInteger buttonIndex) = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            if (self.inputControls && [self.inputControls count]) {
                if (self.isReportRunSuccessful) {
                    [self.delegate performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
                } else {
                    [self.delegate.navigationController popViewControllerAnimated:YES];                    
                }
            } else {
                [self cancelReport];
            }
        }
        [self.icUndoManager undo];
        [self.icUndoManager removeAllActionsWithTarget:self];
    };
    
    UIAlertView *alertView = [UIAlertView localizedAlertWithTitle:@"detail.report.viewer.emptyreport.title"
                                                          message:nil
                                                       completion:alertCompletion
                                                cancelButtonTitle:@"dialog.button.ok"
                                                otherButtonTitles:nil];
    
    if ([self.icUndoManager canUndo]) {
        alertView.message = JMCustomLocalizedString(@"detail.report.viewer.emptyreport.message", nil);
        [alertView addButtonWithTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)];
    }
    
    [alertView show];
    
    
}

@end
