//
// Created by Aleksandr Dakhno on 6/26/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMPrintResourceVC.h"
#import "JMReportSaver.h"
#import "JMReport.h"

@interface JMPrintResourceVC()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation JMPrintResourceVC

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Print";
    [self prepareJob];
}

#pragma mark - Helpers
- (void)prepareJob
{
    JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
    [JMCancelRequestPopup presentWithMessage:@"resource.viewer.print.prepare.title" cancelBlock:^{
        [reportSaver cancelReport];
    }];
    [reportSaver saveReportWithName:[self tempReportName]
                             format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                              pages:nil//[self makePagesFormat]
                            addToDB:NO
                         completion:@weakself(^(NSString *reportURI, NSError *error)) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [JMCancelRequestPopup dismiss];
                                 });
                                 if (error) {
                                     [reportSaver cancelReport];
                                     if (error.code == JSSessionExpiredErrorCode) {
                                         if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                             [self prepareJob];
                                         } else {
                                             [JMUtils showLoginViewAnimated:YES completion:nil];
                                         }
                                     } else {
                                         [JMUtils showAlertViewWithError:error];
                                     }
                                 } else {
                                     NSLog(@"report saved");

                                     NSURL *reportURL = [NSURL fileURLWithPath:[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:reportURI]];
                                     NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
                                     [self.webView loadRequest:request];

//                                     self.printingItem = [NSURL fileURLWithPath:[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:reportURI]];
//                                     [self printResource];
                                 }
                             }@weakselfend];
}

- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
}

@end