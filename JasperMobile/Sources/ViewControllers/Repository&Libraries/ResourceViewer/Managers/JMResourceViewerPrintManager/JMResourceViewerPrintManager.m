/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMResourceViewerPrintManager.m
//  TIBCO JasperMobile
//
#import "JMResourceViewerPrintManager.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JMMainNavigationController.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMThemesManager.h"
#import "JMConstants.h"
#import "JMReportExportTask.h"
#import "JMDashboardExportTask.h"
#import "JMExportManager.h"

@interface JMResourceViewerPrintManager() <UIPrintInteractionControllerDelegate>
@property (nonatomic, strong) JMResource *resource;
@property (nonatomic, strong) UINavigationController *printNavController;
@property (nonatomic, assign) CGSize printSettingsPreferredContentSize;

@property (nonatomic, weak) JMExportTask *currentExportTask;
@end

@implementation JMResourceViewerPrintManager

#pragma mark - Public API

- (void)printResource:(JMResource * __nonnull)resource
 prepearingCompletion:(void(^ __nullable)(void))prepearingCompletion
      printCompletion:(void(^ __nullable)(void))printCompletion
{
    NSAssert(!self.currentExportTask, @"Not finished printing task!!!");
    
    self.resource = resource;
    self.printSettingsPreferredContentSize = CGSizeMake(540, 580);

    __weak __typeof(self) weakSelf = self;
    [self preparePreviewForPrintWithCompletion:^(id printItem, NSError *error) {
        if (prepearingCompletion) {
            prepearingCompletion();
        }
        if (error) {
            if (error.code == JSSessionExpiredErrorCode) {
                [JMUtils showLoginViewAnimated:YES completion:nil];
            } else {
                [JMUtils presentAlertControllerWithError:error completion:nil];
            }
        } else if (printItem) {
            __typeof(self) strongSelf = weakSelf;
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf printItem:printItem
                         withName:strongSelf.resource.resourceLookup.label
                       completion:^(BOOL completed, NSError *error){
                           __typeof(self) strongSelf = weakSelf;
                           [strongSelf cleaningUpAfterPrintingItem:printItem];
                           if (completed) {
                               [strongSelf sendAnalyticsEvents];
                           }
                           if(error){
                               JMLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
                           }
                           if (printCompletion) {
                               printCompletion();
                           }
                       }];
        } else if (printCompletion) {
            printCompletion();
        }
    }];
}

- (void)cancel
{
    [[JMExportManager sharedInstance] cancelTask:self.currentExportTask];
}

#pragma mark - Helpers

- (void)preparePreviewForPrintWithCompletion:(void(^)(id printItem, NSError *error))completion
{
    if (self.resource.type == JMResourceTypeReport) {
        [self prepareReportForPrintingWithCompletion:completion];
    } else if (self.resource.type == JMResourceTypeDashboard) {
        [self prepareDashboardForPrintingWithCompletion:completion];
    } else if (self.userPrepareBlock) {
        completion(self.userPrepareBlock(), nil);
    }
}

- (void)cleaningUpAfterPrintingItem:(id)printItem
{
    if ((self.resource.type == JMResourceTypeReport || self.resource.type == JMResourceTypeDashboard) && [printItem isKindOfClass:[NSURL class]]) {
        [self removeResourceWithURL:printItem];
    } else {
        // TODO: extend for other resources
    }
}

- (void)prepareReportForPrintingWithCompletion:(void(^)(NSURL *resourceURL, NSError *error))completion
{
    JSReport *report = [self.resource modelOfResource];
    NSString *reportName = [self tempResourceName];
    JMReportExportTask *task = [[JMReportExportTask alloc] initWithReport:report
                                                                     name:reportName
                                                                   format:kJS_CONTENT_TYPE_PDF
                                                                    pages:[JSReportPagesRange allPagesRange]];
    
    [task addSavingCompletionBlock:^(JMExportTask * _Nonnull task, NSURL * _Nullable savedResourceFolderURL, NSError * _Nullable error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                NSString *fullReportName = [reportName stringByAppendingPathExtension:kJS_CONTENT_TYPE_PDF];
                NSURL *reportURL = [savedResourceFolderURL URLByAppendingPathComponent:fullReportName];
                completion(reportURL, nil);
            }
        }
    }];
    [[JMExportManager sharedInstance] addExportTask:task];
    self.currentExportTask = task;
}

- (void)prepareDashboardForPrintingWithCompletion:(void(^)(NSURL *resourceURL, NSError *error))completion
{
    if (self.restClient.serverInfo.versionAsFloat < kJS_SERVER_VERSION_CODE_JADE_6_2_0) {
        if (completion && self.userPrepareBlock) {
            completion(self.userPrepareBlock(), nil);
        }
    } else {
        JSDashboard *dashboard = [self.resource modelOfResource];
        NSString *dashboardName = [self tempResourceName];
        JMDashboardExportTask *task = [[JMDashboardExportTask alloc] initWithDashboard:dashboard
                                                                                  name:dashboardName
                                                                                format:kJS_CONTENT_TYPE_PDF];
        
        [task addSavingCompletionBlock:^(JMExportTask * _Nonnull task, NSURL * _Nullable savedResourceFolderURL, NSError * _Nullable error) {
            if (completion) {
                if (error) {
                    if (self.userPrepareBlock) {
                        completion(self.userPrepareBlock(), nil);
                    } else  {
                        completion(nil, error);
                    }
                } else {
                    NSString *fullResourceName = [dashboardName stringByAppendingPathExtension:kJS_CONTENT_TYPE_PDF];
                    NSURL *resourceURL = [savedResourceFolderURL URLByAppendingPathComponent:fullResourceName];
                    completion(resourceURL, nil);
                }
            }
        }];
        [[JMExportManager sharedInstance] addExportTask:task];
        self.currentExportTask = task;
    }
}

- (void)printItem:(id)printingItem withName:(NSString *)itemName completion:(void(^)(BOOL completed, NSError *error))completion
{
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = itemName;
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;

    UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
    printInteractionController.printInfo = printInfo;
    printInteractionController.showsPageRange = YES;
    printInteractionController.printingItem = printingItem;

    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (completion) {
            completion(completed, error);
        }
        // reassign keyWindow status (there is an issue when using showing a report on tv and printing the report).
        [self.controller.view.window makeKeyWindow];
    };

    if ([JMUtils isIphone]) {
        [printInteractionController presentAnimated:YES completionHandler:completionHandler];
    } else {
        if ([JMUtils isSystemVersionEqualOrUp9]) {
            [printInteractionController presentFromBarButtonItem:self.printNavController.navigationItem.rightBarButtonItems.firstObject
                                                        animated:YES
                                               completionHandler:completionHandler];
        } else {
            printInteractionController.delegate = self;
            self.printNavController = [JMMainNavigationController new];
            self.printNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            self.printNavController.preferredContentSize = self.printSettingsPreferredContentSize;
            [printInteractionController presentFromBarButtonItem:self.printNavController.navigationItem.rightBarButtonItems.firstObject
                                                        animated:YES
                                               completionHandler:completionHandler];
        }
    }
}

- (NSString *)tempResourceName
{
    return [[NSUUID UUID] UUIDString];
}

- (void)removeResourceWithURL:(NSURL *)resourceURL
{
    NSString *directoryPath = [resourceURL.path stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

#pragma mark - UIPrintInteractionControllerDelegate
- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    return self.printNavController;
}

- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    [self.controller presentViewController:self.printNavController animated:YES completion:nil];
    UIViewController *printSettingsVC = self.printNavController.topViewController;
    printSettingsVC.navigationItem.leftBarButtonItem.tintColor = [[JMThemesManager sharedManager] barItemsColor];
}

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    [self.printNavController dismissViewControllerAnimated:YES completion:^{
        self.printNavController = nil;
    }];
}

#pragma mark - Analytics
- (void)sendAnalyticsEvents
{
    // Analytics
    NSString *label = kJMAnalyticsResourceLabelSavedResource;
    if (self.resource.type == JMResourceTypeReport) {
        label = [JMUtils isSupportVisualize] ? kJMAnalyticsResourceLabelReportVisualize : kJMAnalyticsResourceLabelReportREST;
    } else if (self.resource.type == JMResourceTypeDashboard) {
        label = ([JMUtils isServerProEdition] && [JMUtils isServerVersionUpOrEqual6]) ? kJMAnalyticsResourceLabelDashboardVisualize : kJMAnalyticsResourceLabelDashboardFlow;
    }
    [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
            kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
            kJMAnalyticsActionKey   : kJMAnalyticsEventActionPrint,
            kJMAnalyticsLabelKey    : label
    }];
}

@end
