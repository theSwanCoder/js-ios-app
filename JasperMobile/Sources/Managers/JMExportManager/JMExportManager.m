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
//  JMExportManager.m
//  TIBCO JasperMobile
//

#import "JMExportManager.h"
#import "JMExportTask.h"
#import "JMExportResource.h"
#import "JMReportSaver.h"
#import "JMSaveReportPagesCell.h"
#import "JMSavedResources+Helpers.h"

@interface JMExportManager()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation JMExportManager

#pragma mark - Life Cycle
+ (instancetype)sharedInstance {
    static JMExportManager *sharedInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       sharedInstance = [JMExportManager new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Public API
- (void)addTaskWithResource:(JMExportResource *)resource
{
    JMExportTask *task = [JMExportTask taskWithResource:resource];
    [self addTaskToQueue:task];
}

- (void)cancelAll
{
    // TODO: implement
}

- (void)cancelTask:(JMExportTask *)task
{
    // TODO: implement
}

- (void)cancelTaskForSavedResource:(JMSavedResources *)savedResource
{
    // TODO: implement
}

#pragma mark - Private API
- (void)addTaskToQueue:(JMExportTask *)task
{
    [self.operationQueue addOperationWithBlock:^{
        [JMSavedResources createSavedResourceWithExportedResource:task.exportResource];
        task.taskState = JMExportTaskStateProgress;
        [self executeTask:task completion:^{
            task.taskState = JMExportTaskStateFinish;
            [task.exportResource.savedResource updateWSTypeWith:kJMSavedReportUnit];
            [self notifyTaskDidEnd:task];
        }];
    }];
}

- (void)executeTask:(JMExportTask *)task completion:(void(^)(void))completion
{
    JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:task.exportResource.resource];
    [reportSaver saveReportWithName:task.exportResource.name
                             format:task.exportResource.format
                              pages:[self makePagesFormatFromPage:task.exportResource.startPage
                                                           toPage:task.exportResource.endPage]
                            addToDB:YES
                         completion:^(JMSavedResources *savedReport, NSError *error) {
                             if (error) {
                                 if (error.code == JSSessionExpiredErrorCode) {
                                     [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                                         if (self.restClient.keepSession && isSessionAuthorized) {
                                             [self executeTask:task completion:completion];
                                         } else {
                                             [JMUtils showLoginViewAnimated:YES completion:nil];
                                         }
                                     }];
                                 } else {
                                     [JMUtils presentAlertControllerWithError:error completion:nil];
                                     [savedReport removeReport];
                                 }
                             } else {
                                 completion();
                             }
                         }];
    task.cancelCompletion = ^{
        [reportSaver cancelReport];
    };
}

#pragma mark - Helpers
- (void)notifyTaskDidEnd:(JMExportTask *)task
{
    UILocalNotification* notification = [UILocalNotification new];
    notification.fireDate = [NSDate date];
    notification.alertBody = task.exportResource.name;
    notification.userInfo = @{
            kJMLocalNotificationKey : kJMExportResourceLocalNotification
    };
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)notifyTaskDidCancel
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMExportedResourceDidCancelNotification
                                                                                         object:nil]];
}

- (NSString *)makePagesFormatFromPage:(NSInteger)fromPage toPage:(NSInteger)toPage
{
    NSString *pagesFormat = nil;
    if (fromPage == toPage) {
        pagesFormat = [NSString stringWithFormat:@"%@", @(fromPage)];
    } else {
        pagesFormat = [NSString stringWithFormat:@"%@-%@", @(fromPage), @(toPage)];
    }
    return pagesFormat;
}

@end