//
//  JMReportLoader.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportLoader.h"
#import "UIAlertView+Additions.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "UIViewController+fetchInputControls.h"

typedef NS_ENUM(NSInteger, JMReportViewerOutputResourceType) {
    JMReportViewerOutputResourceType_None = 0,
    JMReportViewerOutputResourceType_LoadingNow,
    JMReportViewerOutputResourceType_NotFinal,
    JMReportViewerOutputResourceType_Final,
    JMReportViewerOutputResourceType_AlreadyLoaded = JMReportViewerOutputResourceType_NotFinal | JMReportViewerOutputResourceType_Final
};

static NSInteger const kJMReportViewerStatusCheckingInterval = 1.f;
static NSString *const kJMRestStatusReady = @"ready";

@interface JMReportLoader()
@property (nonatomic, strong) NSUndoManager *icUndoManager;
@property (nonatomic, copy) JSRequestFinishedBlock errorExecutionBlock;
@property (nonatomic, copy) void(^loadPageCompletionBlock)(NSString *HTMLString, NSString *baseURL);
@property (nonatomic, assign) BOOL isReportRunSuccessful;
@property (nonatomic, assign) BOOL isReportExequtingStatusReady;
@property (nonatomic, readwrite) BOOL isMultiPageReport;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, assign) NSInteger countOfPages;
@property (nonatomic, strong) NSMutableDictionary *exportIdsDictionary;
@property (nonatomic, assign) JMReportViewerOutputResourceType outputResourceType;
@property (nonatomic, strong) NSTimer *statusCheckingTimer;
@end

@implementation JMReportLoader
objection_requires(@"resourceClient", @"reportClient")

@synthesize reportClient    = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Lifecycle
- (instancetype)initWithResourceLookup:(JSResourceLookup *)resource
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        _icUndoManager = [NSUndoManager new];
        _resourceLookup = resource;
        _errorExecutionBlock = @weakself(^(JSOperationResult *result)){
            NSString *title;
            NSString *message;
            if (result.objects.count && [result.objects[0] isKindOfClass:[JSErrorDescriptor class]]){
                JSErrorDescriptor *error = result.objects[0];
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

#pragma mark - Properties
- (void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage != _currentPage) {
        _currentPage = currentPage;
        if (self.currentPage) {
            [self startExportExecutionForPage:_currentPage];
        }
        [self.delegate reportLoaderDidUpdateState:self];
    }
}

- (void)setCountOfPages:(NSInteger)countOfPages
{
    if (countOfPages != _countOfPages) {
        _countOfPages = countOfPages;
        if (self.currentPage > _countOfPages) {
            self.currentPage = _countOfPages;
        }
        _isMultiPageReport = (self.countOfPages > 1) && (self.countOfPages != kJMCountOfPagesUnknown);
        [self.delegate reportLoaderDidUpdateState:self];
        if ([self isReportEmpty]) {
            [self showAlertEmtpyReport];
        }
    }
}

- (void)setIsMultiPageReport:(BOOL)multiPageReport
{
    if (_isMultiPageReport != multiPageReport) {
        _isMultiPageReport = multiPageReport;
        [self.delegate reportLoaderDidUpdateState:self];
    }
}

- (void)setInputControls:(NSMutableArray *)inputControls
{
    if (self.inputControls != inputControls) {
        _inputControls = inputControls;
    }
}

#pragma mark - Public API

- (void) runReportExecution
{
    [self resetReportViewer];

    [self startShowLoader];
    [self.delegate reportLoaderDidRunReportExecution:self];
    [self.reportClient runReportExecution:self.resourceLookup.uri
                                    async:YES
                             outputFormat:[JSConstants sharedInstance].CONTENT_TYPE_HTML
                              interactive:[self isInteractive]
                                freshData:YES
                         saveDataSnapshot:NO
                         ignorePagination:NO
                           transformerKey:nil
                                    pages:nil
                        attachmentsPrefix:[JSConstants sharedInstance].REST_EXPORT_EXECUTION_ATTACHMENTS_PREFIX_URI
                               parameters:[self parametersForInputControls:self.inputControls]
                                 delegate:[self requestDelegateRunReport]];
}

- (void)startLoadPage:(NSInteger)page withCompletion:(void (^)(NSString *, NSString *))completionBlock
{
    [self startExportExecutionForPage:page];
    self.loadPageCompletionBlock = completionBlock;
}

- (void) cancelReport
{
    [self.statusCheckingTimer invalidate];
    if (!self.isReportExequtingStatusReady) {
        [self.reportClient cancelReportExecution:self.requestId delegate:nil];
    }
    
    [self.delegate reportLoaderDidCancel:self];
}

#pragma mark - Private API
- (void) startExportExecutionForPage:(NSInteger)page
{
    if (!self.requestId) {
        return;
    }
    
    [self.delegate reportLoaderDidBeginExportExecution:self forPageNumber:page];
    
    NSString *exportID = self.exportIdsDictionary[@(page)];
    if (exportID) {
        if (exportID.length) [self loadOutputResourcesForPage:page];
    } else if (page <= self.countOfPages) {
        if (page == self.currentPage) [self startShowLoader];
        
        [self.reportClient runExportExecution:self.requestId
                                 outputFormat:[JSConstants sharedInstance].CONTENT_TYPE_HTML
                                        pages:@(page).stringValue
                            attachmentsPrefix:[JSConstants sharedInstance].REST_EXPORT_EXECUTION_ATTACHMENTS_PREFIX_URI
                                     delegate:[self requestDelegateExportExecutionForPage:page]];
        
        self.exportIdsDictionary[@(page)] = @"";
    }
}

- (void) loadOutputResourcesForPage:(NSInteger)page
{
    if (page == self.currentPage) {
        self.outputResourceType = JMReportViewerOutputResourceType_LoadingNow;
    }
    NSString *exportID = self.exportIdsDictionary[@(page)];
    
    // Fix for JRS version smaller 5.6.0
    NSString *fullExportID = exportID;
    if (self.reportClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) {
        fullExportID = [NSString stringWithFormat:@"%@;pages=%@", exportID, @(page)];
    }
    
    [self.delegate reportLoaderDidBeginLoadOutputResources:self forPageNumber:page];
    [self.reportClient loadReportOutput:self.requestId
                           exportOutput:fullExportID
                          loadForSaving:NO
                                   path:nil
                               delegate:[self requestDelegateLoadOutputResourcesForPage:page]];
}


#pragma mark - Check status

- (void)startStatusChecking
{
    self.statusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportViewerStatusCheckingInterval
                                                                target:self
                                                              selector:@selector(makeStatusChecking)
                                                              userInfo:nil
                                                               repeats:YES];
}

- (void)stopStatusChecking
{
    [self.statusCheckingTimer invalidate];
    BOOL isNotFinal = self.outputResourceType == JMReportViewerOutputResourceType_NotFinal;
    BOOL isLoadingNow = self.outputResourceType == JMReportViewerOutputResourceType_LoadingNow;
    if (isNotFinal && !isLoadingNow) {
        //[self runExportExecutionForPage:self.currentPage];
    }
    
    [self.reportClient getReportExecutionMetadata:self.requestId
                                         delegate:[self requestDelegateStopStatusChecking]];
}

- (void) makeStatusChecking
{
    if (!self.isReportExequtingStatusReady) {
        [self.reportClient getReportExecutionStatus:self.requestId
                                           delegate:[self requestDelegateMakeStatusChecking]];
    } else {
        [self stopStatusChecking];
    }
}

#pragma mark - Helpers
- (BOOL)isReportEmpty
{
    return (self.isReportExequtingStatusReady && self.countOfPages == 0);
}

- (void) resetReportViewer
{
    // set "default" values
    [self setValues:nil
          exportIds:[NSMutableDictionary dictionary]
      inputControls:self.inputControls
       countOfPages:kJMCountOfPagesUnknown
        currentPage:1
      statusIsReady:NO
 outputResourceType:JMReportViewerOutputResourceType_None];
}

- (void) setValues:(NSString *)requestID
         exportIds:(NSMutableDictionary *)exportIds
     inputControls:(NSArray *)inputControls
      countOfPages:(NSInteger)countOfPages
       currentPage:(NSInteger)currentPage
     statusIsReady:(BOOL)status
outputResourceType:(JMReportViewerOutputResourceType)outputResourceType
{
    self.outputResourceType = outputResourceType;
    self.exportIdsDictionary = exportIds;
    self.isReportExequtingStatusReady = status;
    self.requestId = requestID;
    self.inputControls = inputControls;
    self.currentPage = currentPage;
    self.countOfPages = countOfPages;
}

- (BOOL)isInteractive
{
    BOOL interactive = !((self.reportClient.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) &&
                         (self.reportClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_0_0));
    return interactive;
}

- (NSArray *)parametersForInputControls:(NSArray *)inputControls
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in inputControls) {
        [parameters addObject:[[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                value:inputControlDescriptor.selectedValues]];
    }
    return [parameters copy];
}

- (void)startShowLoader
{
    [JMCancelRequestPopup presentWithMessage:@"status.loading"
                                  restClient:self.reportClient
                                 cancelBlock:@weakself(^(void)) { [self cancelReport]; }@weakselfend];
}

- (void)stopShowLoader
{
    [JMCancelRequestPopup dismiss];
}

- (void)showAlertEmtpyReport
{
    void(^alertCompletion)(UIAlertView *alertView, NSInteger buttonIndex) = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            // pressed "Ok" button and show input controls view
            if (self.inputControls && self.inputControls.count) {
                //
                if (self.isReportRunSuccessful) {
                    // add input controls view controller in stack
                    [(UIViewController *)self.delegate performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
                } else {
                    // remove report view controller from stack
                    [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
                }
            } else {
                [self cancelReport];
            }
        } else {
            // show report view
            [self restoreState];
        }
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

#pragma mark - Request delegates
- (JMRequestDelegate *)requestDelegateRunReport
{
    
    void(^completionBlock)(JSOperationResult *result) = @weakself(^(JSOperationResult *result)) {
        [self.delegate reportLoaderDidEndReportExecution:self];
        
        JSReportExecutionResponse *response = result.objects[0];
        self.requestId = response.requestId;
        self.isReportExequtingStatusReady = [response.status.status isEqualToString:kJMRestStatusReady];
        if (self.isReportExequtingStatusReady) {
            self.countOfPages = [response.totalPages integerValue];
        } else {
            [self startStatusChecking];
        }
        
        if (![self isReportEmpty]) {
            // report successfully executed
            self.isReportRunSuccessful = YES;
            [self saveCurrentState];
            [self startExportExecutionForPage:self.currentPage];
        }
    }@weakselfend;
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateWithCompletionBlock:completionBlock
                                                                                    errorBlock:self.errorExecutionBlock
                                                                       viewControllerToDismiss:(!self.requestId) ? (UIViewController *)self.delegate : nil];
    
    return requestDelegate;
}

- (JMRequestDelegate *)requestDelegateExportExecutionForPage:(NSInteger)page
{
    void(^completionBlock)(JSOperationResult *result) = @weakself(^(JSOperationResult *result)) {
        [self.delegate reportLoaderDidEndExportExecution:self forPageNumber:page];
        
        JSExportExecutionResponse *export = result.objects[0];
        self.exportIdsDictionary[@(page)] = export.uuid;
        [self loadOutputResourcesForPage:page];
    }@weakselfend;
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateWithCompletionBlock:completionBlock
                                                                                    errorBlock:self.errorExecutionBlock
                                                                       viewControllerToDismiss:nil];
    return requestDelegate;
}

- (JMRequestDelegate *)requestDelegateLoadOutputResourcesForPage:(NSInteger)page
{
    void(^completionBlock)(JSOperationResult *result) = @weakself(^(JSOperationResult *result)) {
        [self.delegate reportLoaderDidEndLoadOutputResources:self forPageNumber:page];
        
        if ([result.MIMEType isEqualToString:[JSConstants sharedInstance].REST_SDK_MIMETYPE_USED]) {
            [self handleErrorWithOperationResult:result forPage:page];
        } else {
            if (page > 1) {
                self.isMultiPageReport = YES;
            }
            
            self.outputResourceType = result.allHeaderFields[@"output-final"] ? JMReportViewerOutputResourceType_Final : JMReportViewerOutputResourceType_NotFinal;
            
            self.loadPageCompletionBlock(result.bodyAsString, self.reportClient.serverProfile.serverUrl);
        }
    }@weakselfend;
    
    void(^errorBlock)(JSOperationResult *result) = @weakself(^(JSOperationResult *result)) {
        [self handleErrorWithOperationResult:result forPage:page];
    }@weakselfend;

    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:completionBlock
                                                                               errorBlock:errorBlock
                                                                  viewControllerToDismiss: nil
                                                                               showAlerts:NO];
    return requestDelegate;
}

- (void)handleErrorWithOperationResult:(JSOperationResult *)result forPage:(NSInteger)page
{
    JSErrorDescriptor *error = result.objects[0];
    if (page == self.currentPage) {
        self.errorExecutionBlock(result);
    } else {
        if ([error.errorCode isEqualToString:@"illegal.parameter.value.error"] ||
            [error.errorCode isEqualToString:@"export.pages.out.of.range"] ||
            [error.errorCode isEqualToString:@"export.failed"]) {
            self.countOfPages = page - 1;
        }
    }
    //[self.delegate reportLoader:self didFailedLoadHTMLStringWithError:error forPageNumber:page];
}

- (JMRequestDelegate *)requestDelegateMakeStatusChecking
{
    void(^completionBlock)(JSOperationResult *result) = @weakself(^(JSOperationResult *result)) {
        JSExecutionStatus *status = result.objects[0];
        self.isReportExequtingStatusReady = [status.status isEqualToString:kJMRestStatusReady];
        if (self.isReportExequtingStatusReady) {
            [self stopStatusChecking];
        }
    }@weakselfend;
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateWithCompletionBlock:completionBlock
                                                                                    errorBlock:nil
                                                                       viewControllerToDismiss:nil];
    return requestDelegate;
}

- (JMRequestDelegate *)requestDelegateStopStatusChecking
{
    void(^completionBlock)(JSOperationResult *result) = @weakself(^(JSOperationResult *result)) {
        JSReportExecutionResponse *response = result.objects[0];
        self.countOfPages = response.totalPages.integerValue;
    }@weakselfend;
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateWithCompletionBlock:completionBlock
                                                                                    errorBlock:nil
                                                                       viewControllerToDismiss:nil];
    return requestDelegate;
}

#pragma mark - Undo methods
- (void)saveCurrentState
{
    [[self.icUndoManager prepareWithInvocationTarget:self] setValues:self.requestId
                                                           exportIds:self.exportIdsDictionary
                                                       inputControls:self.inputControls
                                                        countOfPages:self.countOfPages
                                                         currentPage:self.currentPage
                                                       statusIsReady:self.isReportExequtingStatusReady
                                                  outputResourceType:self.outputResourceType];
    [self.icUndoManager setActionName:@"ResetChanges"];
}

- (void)restoreState
{
    [self.icUndoManager undo];
    // need save previous state
    [self saveCurrentState];
}



@end
