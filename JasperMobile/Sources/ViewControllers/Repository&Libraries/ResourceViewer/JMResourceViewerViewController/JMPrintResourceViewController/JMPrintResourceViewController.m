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
//  JMPrintResourceViewController.m
//  TIBCO JasperMobile
//

#import "JMPrintResourceViewController.h"
#import "JMReportSaver.h"

@interface JMPrintResourceViewController ()

@property (nonatomic, strong) JMReport *report;
@property (nonatomic, strong) JSResourceLookup *resourceLookup;
@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, strong) id printingItem;
@property (nonatomic, weak) IBOutlet UIButton *printButton;
@end

@implementation JMPrintResourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.printButton setTitle:JMCustomLocalizedString(@"action.title.print", nil)
                      forState:UIControlStateNormal];
}

#pragma mark - Public API
- (void)setReport:(JMReport *)report withWebView:(UIWebView *)webView
{
    self.report = report;
    self.webView = webView;
}

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup withWebView:(UIWebView *)webView
{
    self.resourceLookup = resourceLookup;
    self.webView = webView;
}

#pragma mark - Private API
- (NSString *)jobName
{
    if (self.report) {
        return self.report.resourceLookup.label;
    } else if (self.resourceLookup) {
        return self.resourceLookup.label;
    } else {
        NSString *applicationName = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
        return [NSString stringWithFormat:JMCustomLocalizedString(@"resource.viewer.print.operation.name", nil), applicationName];
    }
}

- (void)prepareForPrint
{
    if (self.report) {
        JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
        [JMCancelRequestPopup presentWithMessage:@"report.viewer.save.saving.status.title" cancelBlock:^{
            [reportSaver cancelReport];
        }];
        [reportSaver saveReportWithName:[self reportName]
                                 format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                                  pages:nil
                                addToDB:NO
                             completion:@weakself(^(NSString *reportURI, NSError *error)) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [JMCancelRequestPopup dismiss];
                                 });
                                 if (error) {
                                     [reportSaver cancelReport];
                                     if (error.code == JSSessionExpiredErrorCode) {
                                         if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                             [self prepareForPrint];
                                         } else {
                                             [JMUtils showLoginViewAnimated:YES completion:nil];
                                         }
                                     } else {
                                         [JMUtils showAlertViewWithError:error];
                                     }
                                 } else {
                                     self.printingItem = [NSURL fileURLWithPath:[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:reportURI]];
                                     [self printResource];
                                 }
                             }@weakselfend];
    } else {
        self.printingItem = [self imageFromWebView];
        [self printResource];
    }
}

- (void)printResource
{
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = self.jobName;
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printInfo = printInfo;
    printController.showsPageRange = NO;
    printController.printingItem = self.printingItem;
    
    UIPrintInteractionCompletionHandler completionHandler = @weakself(^(UIPrintInteractionController *printController, BOOL completed, NSError *error)) {
        if ([self.printingItem isKindOfClass:[NSURL class]]) {
            NSURL *fileURL = (NSURL *)self.printingItem;
            NSString *directoryPath = [fileURL.path stringByDeletingLastPathComponent];
            if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
            }
        }

        if(error){
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }@weakselfend;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([JMUtils isIphone]) {
            [printController presentAnimated:YES completionHandler:completionHandler];
        } else {
            [printController presentFromRect:self.printButton.frame inView:self.view animated:YES completionHandler:completionHandler];
        }
    });
}

- (IBAction)printButtonTapped:(id)sender
{
    [self prepareForPrint];
}

#pragma mark - Helpers
- (UIImage *)imageFromWebView
{
    // Screenshot rendering from webView
    UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, self.webView.opaque, 0.0);
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (NSString *)reportName
{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

@end
