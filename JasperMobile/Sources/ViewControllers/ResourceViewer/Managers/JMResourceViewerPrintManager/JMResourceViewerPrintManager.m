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

@interface JMResourceViewerPrintManager() <UIPrintInteractionControllerDelegate>
@property (nonatomic, strong) JMResource *resource;
@property (nonatomic, strong) UINavigationController *printNavController;
@property (nonatomic, assign) CGSize printSettingsPreferredContentSize;
@end

@implementation JMResourceViewerPrintManager

#pragma mark - Public API

- (void)printResource:(JMResource *)resource completion:(void(^)(void))completion
{
    self.resource = resource;
    self.printSettingsPreferredContentSize = CGSizeMake(540, 580);

    __weak __typeof(self) weakSelf = self;
    [self preparePreviewForPrintWithCompletion:^(id printItem) {
        if (completion) {
            completion();
        }
        if (printItem) {
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
                       }];
        }
    }];
}

#pragma mark - Helpers

- (void)preparePreviewForPrintWithCompletion:(void(^)(id printItem))completion
{
    if (self.prepareBlock) {
        completion(self.prepareBlock());
    } else {
        if (self.resource.type == JMResourceTypeReport) {
            [self prepareReportForPrintingWithCompletion:completion];
        } else if (self.resource.type == JMResourceTypeDashboard) {
            // TODO: implement
        } else {
            // TODO: extend for other resources
        }
    }
}

- (void)cleaningUpAfterPrintingItem:(id)printItem
{
    if (self.resource.type == JMResourceTypeReport) {
        if ([printItem isKindOfClass:[NSURL class]]) {
            NSURL *resourceURL = printItem;
            [self removeResourceWithURL:resourceURL];
        }
    } else if (self.resource.type == JMResourceTypeDashboard) {
        // TODO: implement
    } else {
        // TODO: extend for other resources
    }
}

- (void)prepareReportForPrintingWithCompletion:(void(^)(NSURL *resourceURL))completion
{
    JSReport *report = [self.resource modelOfResource];
    JSReportSaver *reportSaver = [[JSReportSaver alloc] initWithReport:report
                                                            restClient:self.restClient];

    NSString *reportName = [self tempReportName];
    [reportSaver saveReportWithName:reportName
                             format:kJS_CONTENT_TYPE_PDF
                         pagesRange:[JSReportPagesRange allPagesRange]
                         completion:^(NSURL * _Nullable savedReportURL, NSError * _Nullable error) {
                             if (error) {
                                 if (error.code == JSSessionExpiredErrorCode) {
                                     [JMUtils showLoginViewAnimated:YES completion:nil];
                                 } else {
                                     [JMUtils presentAlertControllerWithError:error completion:nil];
                                 }
                             } else {
                                 NSString *fullReportName = [reportName stringByAppendingPathExtension:kJS_CONTENT_TYPE_PDF];
                                 NSURL *reportURL = [savedReportURL URLByAppendingPathComponent:fullReportName];
                                 if (completion) {
                                     completion(reportURL);
                                 }
                             }
                         }];
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

- (NSString *)tempReportName
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