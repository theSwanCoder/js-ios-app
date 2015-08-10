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


#import "JMSavedResourceViewerViewController.h"
#import "JMSavedResources+Helpers.h"

@interface JMSavedResourceViewerViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) JMSavedResources *savedReports;
@property (nonatomic, strong) NSString *changedReportName;
@property (nonatomic, strong) UIWindow *externalWindow;
@property (nonatomic, strong) UIButton *unplugButton;
@property (nonatomic, strong) UIButton *upButton;
@property (nonatomic, strong) UIButton *downButton;
@property (nonatomic, assign) CGFloat currentOffset;
@end

@implementation JMSavedResourceViewerViewController
@synthesize changedReportName;

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.externalWindow = [UIWindow new];

    // unplug button
    CGRect buttonFrame = CGRectMake(0, 0, 200, 50);
    self.unplugButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [self.unplugButton setTitle:@"Unplug" forState:UIControlStateNormal];
    [self.unplugButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.unplugButton addTarget:self action:@selector(unplugExternalWindow) forControlEvents:UIControlEventTouchUpInside];

    // up button
    UIImage *arrowUPImage = [UIImage imageNamed:@"arrow_up"];
    buttonFrame = CGRectMake(0, 0, arrowUPImage.size.width, arrowUPImage.size.height);
    self.upButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [self.upButton setImage:arrowUPImage forState:UIControlStateNormal];
    [self.upButton addTarget:self action:@selector(upAction) forControlEvents:UIControlEventTouchUpInside];

    // up button
    UIImage *arrowDownImage = [UIImage imageNamed:@"arrow_down"];
    buttonFrame = CGRectMake(0, 0, arrowDownImage.size.width, arrowDownImage.size.height);
    self.downButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [self.downButton setImage:arrowDownImage forState:UIControlStateNormal];
    [self.downButton addTarget:self action:@selector(downAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions
- (void)unplugExternalWindow
{
    NSLog(@"unplugExternalWindow");

    [self.unplugButton removeFromSuperview];
    [self.upButton removeFromSuperview];
    [self.downButton removeFromSuperview];

    self.webView.frame = self.view.bounds;
    [self.webView.scrollView setContentOffset:CGPointMake(0, self.currentOffset)];
    [self.view addSubview:self.webView];

    [self.view.window makeKeyAndVisible];
//    self.externalWindow.screen = nil;
}

- (void)upAction
{
    self.currentOffset -= 20;
    if (self.currentOffset < 0) {
        self.currentOffset = 0;
    }
    [self.webView.scrollView setContentOffset:CGPointMake(0, self.currentOffset)];
}

- (void)downAction
{
    self.currentOffset += 20;
    CGFloat maxOffset = self.webView.scrollView.contentSize.height - self.externalWindow.bounds.size.height;
    if (self.currentOffset > maxOffset) {
        self.currentOffset = maxOffset;
    }
    [self.webView.scrollView setContentOffset:CGPointMake(0, self.currentOffset)];
}

#pragma mark - Handle Memory Warnings
- (void)didReceiveMemoryWarning
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:nil baseURL:nil];
    [[UIAlertView alertWithTitle:JMCustomLocalizedString(@"dialod.title.error", nil)
                         message:JMCustomLocalizedString(@"savedreport.viewer.show.resource.error.message", nil) // TODO: replace with the other message
                      completion:@weakself(^(UIAlertView *alertView, NSInteger buttonIndex)) {
                              [self cancelResourceViewingAndExit:YES];
                          }@weakselfend
               cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.ok", nil)
               otherButtonTitles:nil] show];
    
    [super didReceiveMemoryWarning];
}

- (JMSavedResources *)savedReports
{
    if (!_savedReports) {
        _savedReports = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
    }
    
    return _savedReports;
}

- (void)startResourceViewing
{
    NSString *fullReportPath = [JMSavedResources absolutePathToSavedReport:self.savedReports];

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    self.isResourceLoaded = NO;

    if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML]) {
        NSString* content = [NSString stringWithContentsOfFile:fullReportPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        NSURL *url = [NSURL fileURLWithPath:fullReportPath];
        [self.webView loadHTMLString:content baseURL:url];
    } else {
        NSURL *url = [NSURL fileURLWithPath:fullReportPath];
        self.resourceRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:self.resourceRequest];
    }
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    return ([super availableActionForResource:[self resourceLookup]] | JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete | JMMenuActionsViewAction_ExternalDisplay);
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Rename) {
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(@"savedreport.viewer.modify.title", nil)
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)
                                           otherButtonTitles:JMCustomLocalizedString(@"dialog.button.ok", nil), nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = JMCustomLocalizedString(@"savedreport.viewer.modify.reportname", nil);
        textField.delegate = self;
        textField.text = [self.savedReports.label copy];
        
        alertView.tag = action;
        [alertView show];
    } else if(action == JMMenuActionsViewAction_Delete) {
        UIAlertView *alertView  = [UIAlertView localizedAlertWithTitle:@"dialod.title.confirmation"
                                                               message:@"savedreport.viewer.delete.confirmation.message"
                                                              delegate:self
                                                     cancelButtonTitle:@"dialog.button.cancel"
                                                     otherButtonTitles:@"dialog.button.ok", nil];
        alertView.tag = action;
        [alertView show];
    } else if (action == JMMenuActionsViewAction_ExternalDisplay) {
        NSArray *screens = [UIScreen screens];

        [self setupExternalWindow];
        self.currentOffset = self.webView.scrollView.contentOffset.y;
        [self.externalWindow addSubview:self.webView];

        self.externalWindow.hidden = NO;
        [self.externalWindow makeKeyAndVisible];

        [self setupUnplugButton];
        [self.view addSubview:self.unplugButton];

        [self setupUpButton];
        [self.view addSubview:self.upButton];
        [self setupDownButton];
        [self.view addSubview:self.downButton];

        NSLog(@"screens: %@", screens);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *errorMessage = @"";
    UITextField *textField = [alertView textFieldAtIndex:0];
    BOOL validData = [JMUtils validateReportName:textField.text extension:self.savedReports.format errorMessage:&errorMessage];
    if (validData && ![JMSavedResources isAvailableReportName:textField.text format:self.savedReports.format]) {
        validData = NO;
        errorMessage = JMCustomLocalizedString(@"report.viewer.save.name.errmsg.notunique", nil);
    }
    alertView.message = errorMessage;
    
    return validData;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        if (alertView.tag == JMMenuActionsViewAction_Rename) {
            NSString *newName = [alertView textFieldAtIndex:0].text;
            if ([self.savedReports renameReportTo:newName]) {
                self.title = newName;
                self.resourceLookup = [self.savedReports wrapperFromSavedReports];
            }
        } else if (alertView.tag == JMMenuActionsViewAction_Delete) {
            BOOL shouldCloseViewer = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(resourceViewer:shouldCloseViewerAfterDeletingResource:)]) {
                shouldCloseViewer = [self.delegate resourceViewer:self shouldCloseViewerAfterDeletingResource:self.resourceLookup];
            }
            [self cancelResourceViewingAndExit:shouldCloseViewer];
            [self.savedReports removeReport];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(resourceViewer:didDeleteResource:)]) {
                [self.delegate resourceViewer:self didDeleteResource:self.resourceLookup];
            }
        }
    }
}

#pragma mark - Helpers
- (void)setupUnplugButton
{
    CGRect buttonRect = self.unplugButton.frame;
    buttonRect.origin.x = (CGRectGetWidth(self.view.bounds) - CGRectGetWidth(buttonRect))/ 2.0f;
    buttonRect.origin.y = (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(buttonRect))/ 2.0f;
    self.unplugButton.frame = buttonRect;
}

- (void)setupUpButton
{
    CGRect buttonFrame = self.upButton.frame;
    buttonFrame.origin.x = CGRectGetMaxX(self.unplugButton.frame) + 10;
    buttonFrame.origin.y = CGRectGetMinY(self.unplugButton.frame);
    self.upButton.frame = buttonFrame;
}

- (void)setupDownButton
{
    CGRect buttonFrame = self.downButton.frame;
    buttonFrame.origin.x = CGRectGetMaxX(self.unplugButton.frame) + 10;
    buttonFrame.origin.y = CGRectGetMaxY(self.unplugButton.frame) - CGRectGetHeight(buttonFrame);
    self.downButton.frame = buttonFrame;
}

- (void)setupExternalWindow
{
    UIScreen *externalScreen = [UIScreen screens][1];
    UIScreenMode *desiredMode = externalScreen.availableModes.firstObject;
    externalScreen.currentMode = desiredMode;

    // Setup external window
    self.externalWindow.screen = externalScreen;
    self.externalWindow.backgroundColor = [UIColor whiteColor];

    CGRect rect = CGRectZero;
    rect.size = desiredMode.size;
    self.externalWindow.frame = rect;
    self.externalWindow.clipsToBounds = YES;

    self.webView.frame = rect;
}

@end
