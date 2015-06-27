//
// Created by Aleksandr Dakhno on 6/26/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMPrintResourceVC.h"
#import "JMReportSaver.h"
#import "JMReport.h"
#import "JMCancelRequestPopup.h"
#import "JMReportPagesRange.h"

@interface JMPrintResourceVC() <UIWebViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *pagesView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (strong, nonatomic) JMReportSaver *reportSaver;
@end

@implementation JMPrintResourceVC

#pragma mark - NSObject Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Print";

    self.webView.scrollView.showsVerticalScrollIndicator = NO;

    self.fromTextField.inputAccessoryView = [self textFieldToolbar];
    self.toTextField.inputAccessoryView = [self textFieldToolbar];

    self.fromTextField.text = @(1).stringValue;
    self.toTextField.text = @(self.report.countOfPages).stringValue;
    self.reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
    [self prepareJob];

    [self addKeyboardObservers];
}

#pragma mark - Keyboard Observers
- (void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGRect headerViewFrame = self.headerView.frame;
    CGRect pagesViewFrame = self.pagesView.frame;
    CGRect parentViewFrame = self.view.frame;

    headerViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                                (CGRectGetHeight(keyboardFrame) +\
                               CGRectGetHeight(headerViewFrame) +\
                                CGRectGetHeight(pagesViewFrame));

    pagesViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                               (CGRectGetHeight(keyboardFrame) +\
                               CGRectGetHeight(pagesViewFrame));

    [UIView animateWithDuration:animationDuration animations:^{
        self.headerView.frame = headerViewFrame;
        self.pagesView.frame = pagesViewFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGRect headerViewFrame = self.headerView.frame;
    CGRect footerViewFrame = self.footerView.frame;
    CGRect pagesViewFrame = self.pagesView.frame;
    CGRect parentViewFrame = self.view.frame;

    headerViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                              (CGRectGetHeight(footerViewFrame) +\
                               CGRectGetHeight(headerViewFrame) +\
                                CGRectGetHeight(pagesViewFrame));

    pagesViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                             (CGRectGetHeight(footerViewFrame) +\
                               CGRectGetHeight(pagesViewFrame));

    [UIView animateWithDuration:animationDuration animations:^{
        self.headerView.frame = headerViewFrame;
        self.pagesView.frame = pagesViewFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Actions
- (IBAction)showPages:(UISwitch *)sender
{
    CGRect webViewFrame = self.webView.frame;
    CGRect headerViewFrame = self.headerView.frame;
    CGRect footerViewFrame = self.footerView.frame;
    CGFloat footerViewHeight = footerViewFrame.size.height;
    CGRect pagesViewFrame = self.pagesView.frame;
    CGFloat pagesViewHeight = pagesViewFrame.size.height;
    if (!sender.on) {
        NSLog(@"show pages");
        headerViewFrame.origin.y -= pagesViewHeight;
        webViewFrame.size.height -= pagesViewHeight;
        pagesViewFrame.origin.y -= pagesViewHeight - footerViewHeight;
    } else {
        NSLog(@"hide pages");
        headerViewFrame.origin.y += pagesViewHeight;
        webViewFrame.size.height += pagesViewHeight;
        pagesViewFrame.origin.y += pagesViewHeight - footerViewHeight;
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.headerView.frame = headerViewFrame;
        self.webView.frame = webViewFrame;
        self.pagesView.frame = pagesViewFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)done:(id)sender
{
    [self.activeTextField resignFirstResponder];
}

- (void)cancel:(id)sender
{
    [self.activeTextField resignFirstResponder];
}

- (IBAction)printAction:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Update preview"]) {
        NSLog(@"update preview");
        [self.printButton setTitle:@"Print" forState:UIControlStateNormal];
        [self prepareJob];
    }
}

#pragma mark - Helpers
- (void)prepareJob
{
    [JMCancelRequestPopup presentWithMessage:@"resource.viewer.print.prepare.title" cancelBlock:^{
        [self.reportSaver cancelReport];
    }];

    NSUInteger startPage = self.fromTextField.text.integerValue;
    NSUInteger endPage = self.toTextField.text.integerValue;
    JMReportPagesRange *pagesRange = [JMReportPagesRange rangeWithStartPage:startPage endPage:endPage];

    [self.reportSaver saveReportWithName:[self tempReportName]
                             format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                         pagesRange:pagesRange
                            addToDB:NO
                         completion:@weakself(^(NSString *reportURI, NSError *error)) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [JMCancelRequestPopup dismiss];
                                 });
                                 if (error) {
                                     [self.reportSaver cancelReport];
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

#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    NSLog(@"webView.pageCount: %@", @(webView.pageCount));
//    NSLog(@"webView.pageLength: %@", @(webView.pageLength));
//    NSLog(@"request: %@", request);
//
//    return YES;
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    NSLog(@"webView.pageCount: %@", @(webView.pageCount));
//    NSLog(@"webView.pageLength: %@", @(webView.pageLength));
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    NSLog(@"webView.pageCount: %@", @(webView.pageCount));
//    NSLog(@"webView.pageLength: %@", @(webView.pageLength));
//}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.integerValue > self.report.countOfPages) {
        // show alert
        textField.text = @(self.report.countOfPages).stringValue;
    }

    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self.printButton setTitle:@"Update preview" forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - View Helpers
- (UIToolbar *)textFieldToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:@[cancel, flexibleSpace, done]];

    return toolbar;
}

@end