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

static NSTimeInterval const kJMReportExecutorStatusCheckingInterval = 5;
static NSString *const kJMReportExecutorRestStatusReady = @"ready";

@interface JMReportExecutor()
@property (nonatomic, weak) JMReport *report;
@property (nonatomic, copy) void(^executeCompletion)(JSReportExecutionResponse *executionResponse, NSError *error);
@property (nonatomic, copy) void(^exportCompletion)(JSExportExecutionResponse *exportResponse, NSError *error);
@property (nonatomic, strong) NSTimer *statusCheckingTimer;
@property (nonatomic, assign) BOOL shouldExecuteWithFreshData;
@property (nonatomic, assign) BOOL shouldIgnorePagination;
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

    [self.restClient runReportExecution:self.report.resourceLookup.uri
                                  async:self.shouldExecuteAsync
                           outputFormat:self.format
                            interactive:self.interactive
                              freshData:self.shouldExecuteWithFreshData
                       saveDataSnapshot:YES // TODO: what does this parameter mean
                       ignorePagination:self.shouldIgnorePagination
                         transformerKey:nil // TODO: what does this parameter mean
                                  pages:self.pages
                      attachmentsPrefix:self.attachmentsPrefix
                             parameters:self.report.reportParameters
                        completionBlock:@weakself(^(JSOperationResult *result)) {

                                if (result.error) {
                                    if (self.executeCompletion) {
                                        self.executeCompletion(nil, result.error);
                                    }
                                } else {
                                    JSReportExecutionResponse *executionResponse = result.objects.firstObject;
                                    if (self.executeCompletion) {
                                        self.executeCompletion(executionResponse, nil);
                                    }
                                }
                            }@weakselfend];
}

- (void)exportWithExecutionResponse:(JSReportExecutionResponse *)executionResponse completion:(void(^)(JSExportExecutionResponse *exportResponse, NSError *error))completion
{
    self.exportCompletion = completion;

//    NSString *executionID = executionResponse.requestId;
    NSArray *exports = executionResponse.exports;
    JSExportExecutionResponse *exportResponse = exports.firstObject;
//    JSExecutionStatus *exportStatus = exportResponse.status;

    if (self.exportCompletion) {
        self.exportCompletion(exportResponse, nil);
    }
}

#pragma mark - Private API


#pragma mark - Status Checking
- (void)startCheckingExportStatusWithID:(NSString *)identifier
{
    NSDictionary *userInfo = @{
            @"identifier": identifier
    };
    self.statusCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kJMReportExecutorStatusCheckingInterval
                                                                target:self
                                                              selector:@selector(makeStatusChecking:)
                                                              userInfo:userInfo
                                                               repeats:YES];
}

- (void) makeStatusChecking:(NSTimer *)timer
{
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

                                                     if (isExportStatusReady) {
                                                         if (self.statusCheckingTimer.valid) {
                                                             [self.statusCheckingTimer invalidate];
                                                         }

                                                         if (self.exportCompletion) {
                                                             self.exportCompletion(exportResponse, nil);
                                                         }
                                                     }
                                                 }
                                             } @weakselfend];

}

@end