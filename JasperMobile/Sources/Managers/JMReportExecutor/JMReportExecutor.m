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
//  JMReportExecutor.m
//  TIBCO JasperMobile
//

#import "JMReportExecutor.h"
#import "JMReport.h"
#import "JMReportPagesRange.h"

static NSTimeInterval const kJMReportExecutorStatusCheckingInterval = 5;
static NSString *const kJMReportExecutorRestStatusReady = @"ready";
static NSString *const kJMReportExecutorRestStatusQueued = @"queued";
static NSString *const kJMReportExecutorRestStatusExecution = @"execution";
static NSString *const kJMReportExecutorRestStatusCancelled = @"cancelled";

@interface JMReportExecutor()
@property (nonatomic, weak) JMReport *report;
@property (nonatomic, copy) void(^executeCompletion)(JSReportExecutionResponse *executionResponse, NSError *error);
@property (nonatomic, copy) void(^exportCompletion)(JSExportExecutionResponse *exportResponse, NSError *error);
@property (nonatomic, strong) NSTimer *executionStatusCheckingTimer;
@property (nonatomic, strong) NSTimer *exportStatusCheckingTimer;
@property (nonatomic, assign) BOOL shouldExecuteWithFreshData;
@property (nonatomic, assign) BOOL shouldIgnorePagination;
//
@property (nonatomic, strong) JSReportExecutionResponse *executionResponse;
@end

@implementation JMReportExecutor

#pragma mark - Life Cycle
- (instancetype)initWithReport:(JMReport *)report
{
    self = [super init];
    if (self) {
        _report = report;
    }
    return self;
}

+ (instancetype)executorWithReport:(JMReport *)report
{
    return [[self alloc] initWithReport:report];
}

#pragma mark - Pubilc API
- (void)executeWithCompletion:(void(^)(JSReportExecutionResponse *executionResponse, NSError *error))completion
{
    self.executeCompletion = completion;

    if (self.executionResponse) {
        if (self.executeCompletion) {
            self.executeCompletion(self.executionResponse, nil);
        }
    } else {
        [self.restClient runReportExecution:self.report.resourceLookup.uri
                                      async:self.shouldExecuteAsync
                               outputFormat:self.format
                                interactive:self.interactive
                                  freshData:self.shouldExecuteWithFreshData
                           saveDataSnapshot:YES // TODO: what does this parameter mean
                           ignorePagination:self.shouldIgnorePagination
                             transformerKey:nil // TODO: what does this parameter mean
                                      pages:nil
                          attachmentsPrefix:self.attachmentsPrefix
                                 parameters:self.report.reportParameters
                            completionBlock:@weakself(^(JSOperationResult *result)) {

                                    if (result.error) {
                                        NSLog(@"error: %@", result.error);
                                        if (self.executeCompletion) {
                                            self.executeCompletion(nil, result.error);
                                        }
                                    } else {
                                        NSLog(@"success report execution");
                                        self.executionResponse = result.objects.firstObject;
                                        NSLog(@"execution status: %@", self.executionResponse.status);

                                        if ([self isExportForAllPages]) {
                                            if (self.executeCompletion) {
                                                self.executeCompletion(self.executionResponse, nil);
                                            }
                                        } else {
                                            JSExecutionStatus *executionStatus = self.executionResponse.status;
                                            BOOL isExecutionStatusReady = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                            BOOL isExecutionStatusQueued = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusQueued];
                                            if (isExecutionStatusReady) {
                                                if (self.executeCompletion) {
                                                    self.executeCompletion(self.executionResponse, nil);
                                                }
                                            } else if (isExecutionStatusQueued) {
                                                NSString *executionID = self.executionResponse.requestId;
                                                [self startCheckingExecutionStatusWithID:executionID];
                                            } else {
                                                if (self.executeCompletion) {
                                                    self.executeCompletion(nil, nil);
                                                }
                                            }
                                        }
                                    }
                                }@weakselfend];
    }
}

- (void)exportWithCompletion:(void(^)(JSExportExecutionResponse *exportResponse, NSError *error))completion
{
    self.exportCompletion = completion;

    NSString *executionID = self.executionResponse.requestId;
    if ([self isExportForAllPages]) {
        NSArray *exports = self.executionResponse.exports;

        JSExportExecutionResponse *exportResponse = exports.firstObject;
        JSExecutionStatus *exportStatus = exportResponse.status;

        NSLog(@"export status: %@", exportStatus.status);
        BOOL isExportStatusReady = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
        if (isExportStatusReady) {
            if (self.exportCompletion) {
                self.exportCompletion(exportResponse, nil);
            }
        } else {
            [self startCheckingExportStatusWithID:executionID];
        }
    } else {
        NSLog(@"export only from page: %@, to page: %@", @(self.pagesRange.startPage), @(self.pagesRange.endPage));
        [self.restClient runExportExecution:executionID
                               outputFormat:self.format
                                      pages:self.pagesRange.pagesFormat
                          attachmentsPrefix:self.attachmentsPrefix
                            completionBlock:@weakselfnotnil(^(JSOperationResult *result)) {

                                    if (result.error) {
                                        completion(nil, result.error);
                                    } else {
                                        JSExportExecutionResponse *exportResponse = result.objects.firstObject;
                                        JSExecutionStatus *exportStatus = exportResponse.status;

                                        BOOL isExportStatusReady = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                        BOOL isExportStatusExecution = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusExecution];
                                        BOOL isExportStatusQueued = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusQueued];
                                        BOOL isExportStatusCancelled = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusCancelled];
                                        NSLog(@"export status: %@", exportStatus.status);

                                        if (isExportStatusReady) {
                                            if (self.exportCompletion) {
                                                self.exportCompletion(exportResponse, nil);
                                            }
                                        } else if (isExportStatusExecution || isExportStatusQueued) {
                                            [self startCheckingExportStatusWithID:executionID];
                                        } else if (isExportStatusCancelled) {
                                            if (self.exportCompletion) {
                                                self.exportCompletion(nil, nil);
                                            }
                                        }
                                    }
                                } @weakselfend];
    }
}

#pragma mark - Private API

#pragma mark - Execution Status Checking
- (void)startCheckingExecutionStatusWithID:(NSString *)identifier
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSDictionary *userInfo = @{
            @"identifier": identifier
    };
    self.executionStatusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportExecutorStatusCheckingInterval
                                                                target:self
                                                              selector:@selector(makeExecutionStatusChecking:)
                                                              userInfo:userInfo
                                                               repeats:YES];
}

- (void)makeExecutionStatusChecking:(NSTimer *)timer
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSString *identifier = timer.userInfo[@"identifier"];
    // TODO: replace with a lightwight request for checking status
    [self.restClient reportExecutionMetadataForRequestId:identifier
                                         completionBlock:@weakselfnotnil(^(JSOperationResult *result)) {
                                                 if (!result.error) {
                                                     JSReportExecutionResponse *executionResponse = result.objects.firstObject;
                                                     NSLog(@"execution status: %@", executionResponse.status);

                                                     JSExecutionStatus *executionStatus = executionResponse.status;
                                                     BOOL isExecutionStatusReady = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusReady];

                                                     if (isExecutionStatusReady) {
                                                         if (self.executionStatusCheckingTimer.valid) {
                                                             [self.executionStatusCheckingTimer invalidate];
                                                         }

                                                         if (self.executeCompletion) {
                                                             self.executeCompletion(executionResponse, nil);
                                                         }
                                                     }
                                                 } else {
                                                     NSLog(@"error: %@", result.error);
                                                 }
                                             } @weakselfend];

}

#pragma mark - Export Status Checking
- (void)startCheckingExportStatusWithID:(NSString *)identifier
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSDictionary *userInfo = @{
            @"identifier": identifier
    };
    self.exportStatusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportExecutorStatusCheckingInterval
                                                                target:self
                                                              selector:@selector(makeExportStatusChecking:)
                                                              userInfo:userInfo
                                                               repeats:YES];
}

- (void)makeExportStatusChecking:(NSTimer *)timer
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSString *identifier = timer.userInfo[@"identifier"];
    // TODO: replace with a lightwight request for checking status
    [self.restClient reportExecutionMetadataForRequestId:identifier
                                         completionBlock:@weakselfnotnil(^(JSOperationResult *result)) {
                                                 if (!result.error) {
                                                     JSReportExecutionResponse *executionResponse = result.objects.firstObject;

                                                     NSArray *exports = executionResponse.exports;
                                                     JSExportExecutionResponse *exportResponse = exports.firstObject;
                                                     JSExecutionStatus *exportStatus = exportResponse.status;

                                                     BOOL isExportStatusReady = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                                     BOOL isExportStatusCancelled = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusCancelled];

                                                     NSLog(@"export status: %@", exportStatus.status);
                                                     if (isExportStatusReady) {
                                                         if (self.exportStatusCheckingTimer.valid) {
                                                             [self.exportStatusCheckingTimer invalidate];
                                                         }

                                                         if (self.exportCompletion) {
                                                             self.exportCompletion(exportResponse, nil);
                                                         }
                                                     } else if (isExportStatusCancelled) {
                                                         if (self.exportStatusCheckingTimer.valid) {
                                                             [self.exportStatusCheckingTimer invalidate];
                                                         }

                                                         if (self.exportCompletion) {
                                                             self.exportCompletion(nil, nil);
                                                         }
                                                     }
                                                 } else {
                                                     NSLog(@"error: %@", result.error);
                                                 }
                                             } @weakselfend];

}

#pragma mark - Helpers
- (BOOL)isExportForAllPages
{
    // TODO: investigate all cases
    BOOL isExportForAllPages = self.pagesRange.endPage == self.report.countOfPages;
    return isExportForAllPages;
}

@end