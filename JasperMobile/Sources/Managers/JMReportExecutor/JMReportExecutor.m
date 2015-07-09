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

static NSTimeInterval const kJMReportExecutorStatusCheckingInterval = 1;
static NSString *const kJMReportExecutorRestStatusReady = @"ready";
static NSString *const kJMReportExecutorRestStatusQueued = @"queued";
static NSString *const kJMReportExecutorRestStatusExecution = @"execution";
static NSString *const kJMReportExecutorRestStatusCancelled = @"cancelled";
static NSString *const kJMReportExecutorRestStatusFailed = @"failed";

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
@property (nonatomic, strong) JSExportExecutionResponse *exportResponse;
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
                                        JSReportExecutionResponse *executionResponse = result.objects.firstObject;

                                        self.executionResponse = executionResponse;

                                        if ([self isExportForAllPages]) {
                                            if (self.executeCompletion) {
                                                self.executeCompletion(self.executionResponse, nil);
                                            }
                                        } else {
                                            JSExecutionStatus *executionStatus = self.executionResponse.status;
                                            BOOL isExecutionStatusReady = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                            BOOL isExecutionStatusQueued = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusQueued];
                                            BOOL isExecutionStatusExecution = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusExecution];

                                            if (isExecutionStatusReady) {
                                                if (self.executeCompletion) {
                                                    self.executeCompletion(self.executionResponse, nil);
                                                }
                                            } else if (isExecutionStatusQueued || isExecutionStatusExecution) {
                                                [self startCheckingExecutionStatus];
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

- (void)exportWithCompletion:(void(^)(JSExportExecutionResponse *exportResponse, NSError *error))completion {
    self.exportCompletion = completion;

    NSString *executionID = self.executionResponse.requestId;
    if ([self isExportForAllPages]) {
        NSArray *exports = self.executionResponse.exports;

        self.exportResponse = exports.firstObject;
        JSExecutionStatus *exportStatus = self.exportResponse.status;

        BOOL isExportStatusReady = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
        if (isExportStatusReady) {
            if (self.exportCompletion) {
                self.exportCompletion(self.exportResponse, nil);
            }
        } else {
            [self startCheckingExportStatus];
        }
    } else {
        [self.restClient runExportExecution:executionID
                               outputFormat:self.format
                                      pages:self.pagesRange.pagesFormat
                          attachmentsPrefix:self.attachmentsPrefix
                            completionBlock:@weakselfnotnil(^(JSOperationResult *result)) {

                                    if (result.error) {
                                        if (self.exportCompletion) {
                                            self.exportCompletion(nil, result.error);
                                        }
                                    } else {
                                        self.exportResponse = result.objects.firstObject;
                                        JSExecutionStatus *exportStatus = self.exportResponse.status;

                                        BOOL isExportStatusReady = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                        BOOL isExportStatusExecution = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusExecution];
                                        BOOL isExportStatusQueued = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusQueued];
                                        BOOL isExportStatusCancelled = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusCancelled];
                                        BOOL isExportStatusFailed = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusFailed];

                                        if (isExportStatusReady) {
                                            if (self.exportCompletion) {
                                                self.exportCompletion(self.exportResponse, nil);
                                            }
                                        } else if (isExportStatusExecution || isExportStatusQueued || isExportStatusCancelled) {
                                            [self startCheckingExportStatus];
                                        } else if (isExportStatusFailed) {
                                            if (self.exportCompletion) {
                                                self.exportCompletion(nil, nil);
                                            }
                                        }
                                    }
                                }@weakselfend];
    }
}
#pragma mark - Private API

#pragma mark - Execution Status Checking
- (void)startCheckingExecutionStatus
{
    self.executionStatusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportExecutorStatusCheckingInterval
                                                                         target:self
                                                                       selector:@selector(executionStatusChecking)
                                                                       userInfo:nil
                                                                        repeats:YES];
}

- (void)executionStatusChecking
{
    NSString *executionID = self.executionResponse.requestId;
    [self.restClient reportExecutionStatusForRequestId:executionID
                                       completionBlock:@weakselfnotnil(^(JSOperationResult *result)) {
                                               if (!result.error) {
                                                   JSExecutionStatus *executionStatus = result.objects.firstObject;
                                                   BOOL isExecutionStatusReady = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                                   BOOL isExportStatusFailed = [executionStatus.status isEqualToString:kJMReportExecutorRestStatusFailed];

                                                   if (isExecutionStatusReady) {
                                                       if (self.executionStatusCheckingTimer.valid) {
                                                           [self.executionStatusCheckingTimer invalidate];
                                                       }

                                                       if (self.executeCompletion) {
                                                           self.executeCompletion(self.executionResponse, nil);
                                                       }
                                                   } else if (isExportStatusFailed) {
                                                       if (self.executeCompletion) {
                                                           self.executeCompletion(nil, nil);
                                                       }
                                                   }
                                               } else {
                                                   if (self.executeCompletion) {
                                                       self.executeCompletion(nil, result.error);
                                                   }
                                               }
                                           } @weakselfend];

}

#pragma mark - Export Status Checking
- (void)startCheckingExportStatus
{
    self.exportStatusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportExecutorStatusCheckingInterval
                                                                      target:self
                                                                    selector:@selector(exportStatusChecking)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

- (void)exportStatusChecking
{
    NSString *executionID = self.executionResponse.requestId;
    NSString *exportOutput = self.exportResponse.uuid;
    [self.restClient exportExecutionStatusWithExecutionID:executionID
                                             exportOutput:exportOutput
                                               completion:@weakselfnotnil(^(JSOperationResult *result)) {
                                                       if (!result.error) {
                                                           JSExecutionStatus *exportStatus = result.objects.firstObject;

                                                           BOOL isExportStatusReady = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusReady];
                                                           BOOL isExportStatusFailed = [exportStatus.status isEqualToString:kJMReportExecutorRestStatusFailed];

                                                           if (isExportStatusReady) {
                                                               if (self.exportStatusCheckingTimer.valid) {
                                                                   [self.exportStatusCheckingTimer invalidate];
                                                               }

                                                               [self fetchExportFromMetadataWithCompletion:^(JSExportExecutionResponse *exportResponse, NSError *error) {
                                                                   if (self.exportCompletion) {
                                                                       self.exportCompletion(exportResponse, nil);
                                                                   }
                                                               }];
                                                           } else if (isExportStatusFailed) {
                                                               if (self.exportStatusCheckingTimer.valid) {
                                                                   [self.exportStatusCheckingTimer invalidate];
                                                               }

                                                               if (self.exportCompletion) {
                                                                   self.exportCompletion(nil, nil);
                                                               }
                                                           }
                                                       } else {
                                                           if (self.exportCompletion) {
                                                               self.exportCompletion(nil, result.error);
                                                           }
                                                       }
                                                   }@weakselfend];

}

#pragma mark - Helpers
- (BOOL)isExportForAllPages
{
    // TODO: investigate all cases

    BOOL isMultipageReport = self.report.isMultiPageReport;
    if (!isMultipageReport) {
        return YES;
    }

    BOOL isEmptyRange = self.pagesRange.startPage == 0 && self.pagesRange.endPage == 0;
    if (isEmptyRange) {
        return YES;
    }

    BOOL isExportForAllPages = self.pagesRange.endPage == self.report.countOfPages && self.pagesRange.startPage == 1;
    return isExportForAllPages;
}

- (void)fetchExportFromMetadataWithCompletion:(void(^)(JSExportExecutionResponse *exportResponse, NSError *error))completion
{
    NSString *executionID = self.executionResponse.requestId;
    [self.restClient reportExecutionMetadataForRequestId:executionID
                                         completionBlock:@weakselfnotnil(^(JSOperationResult *result)) {
                                                 if (result.error) {
                                                     if (completion) {
                                                         completion(nil, result.error);
                                                     }
                                                 } else {
                                                     JSReportExecutionResponse *executionResponse = result.objects.firstObject;

                                                     NSArray *exports = executionResponse.exports;

                                                     JSExportExecutionResponse *exportResponse;
                                                     for (JSExportExecutionResponse *export in exports) {
                                                         if ([export.uuid isEqualToString:self.exportResponse.uuid]) {
                                                             exportResponse = export;
                                                             break;
                                                         }
                                                     }

                                                     if (completion) {
                                                         completion(exportResponse, nil);
                                                     }
                                                 }
                                         }@weakselfend];
}

@end