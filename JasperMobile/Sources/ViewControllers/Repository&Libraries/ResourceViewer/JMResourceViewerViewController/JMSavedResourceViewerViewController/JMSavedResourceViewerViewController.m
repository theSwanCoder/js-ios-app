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


#import "JMSavedResourceViewerViewController.h"
#import "JMSavedResources+Helpers.h"
#import "JMReportSaver.h"
#import "JSResourceLookup+Helpers.h"

@interface JMSavedResourceViewerViewController () <UIDocumentInteractionControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) JMSavedResources *savedReports;
@property (nonatomic, strong) NSString *changedReportName;
@property (nonatomic) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) JMReportSaver *reportSaver;
@property (nonatomic, strong) NSString *savedResourcePath;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation JMSavedResourceViewerViewController
@synthesize changedReportName;

#pragma mark - Handle Memory Warnings
- (void)didReceiveMemoryWarning
{
    [self.webView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];

#warning WHY ONLY FOR SAVED REPORT VIEWER WE HANDLE MEMORY WARNINGS???
    NSString *errorMessage = JMCustomLocalizedString(@"savedreport.viewer.show.resource.error.message", nil);
    NSError *error = [NSError errorWithDomain:@"dialod.title.error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    __weak typeof(self) weakSelf = self;
    [JMUtils presentAlertControllerWithError:error completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf cancelResourceViewingAndExit:YES];
    }];

    [super didReceiveMemoryWarning];
}

- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    [self.documentController dismissMenuAnimated:YES];

    if (self.savedResourcePath) {
        [self removeSavedResource];
    }

    [super cancelResourceViewingAndExit:exit];
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
    if ([self.resourceLookup isFile]) {
        [self showRemoteResource];
    } else {
        [self showSavedResource];
    }

    // Analytics
    NSString *resourcesType = @"Saved Item (Unknown type)";
    if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML]) {
        resourcesType = @"Saved Item (HTML)";
    } else if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF]) {
        resourcesType = @"Saved Item (PDF)";
    } else if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_XLS]) {
        resourcesType = @"Saved Item (XLS)";
    }
    [JMUtils logEventWithName:@"User opened resource"
                 additionInfo:@{
                         @"Resource's Type" : resourcesType
                 }];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    return ([super availableActionForResource:[self resourceLookup]] | JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete | JMMenuActionsViewAction_OpenIn);
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Rename) {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertTextDialogueControllerWithLocalizedTitle:@"savedreport.viewer.modify.title"
                                                                                                      message:nil
        textFieldConfigurationHandler:^(UITextField * _Nonnull textField) {
            __strong typeof(self) strongSelf = weakSelf;
            textField.placeholder = JMCustomLocalizedString(@"savedreport.viewer.modify.reportname", nil);
            textField.text = [strongSelf.resourceLookup.label copy];
        } textValidationHandler:^NSString * _Nonnull(NSString * _Nullable text) {
            NSString *errorMessage = nil;
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [JMUtils validateReportName:text errorMessage:&errorMessage];
                if (!errorMessage && ![JMSavedResources isAvailableReportName:text format:strongSelf.savedReports.format]) {
                    errorMessage = JMCustomLocalizedString(@"report.viewer.save.name.errmsg.notunique", nil);
                }
            }
            return errorMessage;
        } textEditCompletionHandler:^(NSString * _Nullable text) {
            __strong typeof(self) strongSelf = weakSelf;
            if ([strongSelf.savedReports renameReportTo:text]) {
                strongSelf.title = text;
                strongSelf.resourceLookup = [strongSelf.savedReports wrapperFromSavedReports];
                [strongSelf setupRightBarButtonItems];
                [strongSelf startResourceViewing];
            }
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if(action == JMMenuActionsViewAction_Delete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.confirmation"
                                                                                          message:@"savedreport.viewer.delete.confirmation.message"
                                                                                cancelButtonTitle:@"dialog.button.cancel"
                                                                          cancelCompletionHandler:nil];
        __weak typeof(self) weakSelf = self;
        [alertController addActionWithLocalizedTitle:@"dialog.button.ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
            __strong typeof(self) strongSelf = weakSelf;
            BOOL shouldCloseViewer = YES;
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(resourceViewer:shouldCloseViewerAfterDeletingResource:)]) {
                shouldCloseViewer = [strongSelf.delegate resourceViewer:strongSelf shouldCloseViewerAfterDeletingResource:strongSelf.resourceLookup];
            }
            [strongSelf cancelResourceViewingAndExit:shouldCloseViewer];
            [strongSelf.savedReports removeReport];

            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(resourceViewer:didDeleteResource:)]) {
                [strongSelf.delegate resourceViewer:strongSelf didDeleteResource:strongSelf.resourceLookup];
            }
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (action == JMMenuActionsViewAction_OpenIn) {
        self.documentController = [self setupDocumentControllerWithURL:self.resourceRequest.URL
                                                         usingDelegate:self];

        BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        if (!canOpen) {
            NSString *errorMessage = JMCustomLocalizedString(@"error.openIn.message", nil);
            NSError *error = [NSError errorWithDomain:@"dialod.title.error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
    }
}

#pragma mark - Helpers
- (UIDocumentInteractionController *) setupDocumentControllerWithURL: (NSURL *) fileURL
                                                       usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

#pragma mark - Viewers
- (void)showSavedResource
{
    NSString *fullReportPath = [JMSavedResources absolutePathToSavedReport:self.savedReports];
    NSURL *url = [NSURL fileURLWithPath:fullReportPath];
    [self showResourceWithURL:url];
}

- (void)showRemoteResource
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:^{
        [self cancelResourceViewingAndExit:YES];
    }];

    __typeof(self) weakSelf = self;
    [self.restClient contentResourceWithResourceLookup:self.resourceLookup
                                            completion:^(JSContentResource *resource, NSError *error) {
                                                __typeof(self) strongSelf = weakSelf;
                                                [strongSelf stopShowLoader];
                                                if (error) {
                                                    [strongSelf showErrorWithMessage:error.localizedDescription
                                                                          completion:^{
                                                                              [strongSelf cancelResourceViewingAndExit:YES];
                                                                          }];
                                                } else {
                                                    if ([strongSelf isSupportedResource:resource]) {

                                                        [self startShowLoaderWithMessage:@"status.loading" cancelBlock:^{
                                                            [self cancelResourceViewingAndExit:YES];
                                                        }];

                                                        NSString *resourcePath = [NSString stringWithFormat:@"%@/rest_v2/resources%@", strongSelf.restClient.serverProfile.serverUrl, resource.uri];
                                                        NSURL *url = [NSURL URLWithString:resourcePath];
                                                        __typeof(self) weakSelf = strongSelf;
                                                        [strongSelf.reportSaver downloadResourceFromURL:url
                                                                                             completion:^(NSString *outputResourcePath, NSError *error) {
                                                                                                 __typeof(self) strongSelf = weakSelf;
                                                                                                 [strongSelf stopShowLoader];
                                                                                                 if (error) {
                                                                                                     [strongSelf showErrorWithMessage:error.localizedDescription
                                                                                                                           completion:^{
                                                                                                                               [strongSelf cancelResourceViewingAndExit:YES];
                                                                                                                           }];
                                                                                                 } else {
                                                                                                     strongSelf.savedResourcePath = outputResourcePath;
                                                                                                     NSURL *savedResourceURL = [NSURL fileURLWithPath:outputResourcePath];
                                                                                                     if ([resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_IMG]) {
                                                                                                         [strongSelf showImageWithURL:savedResourceURL];
                                                                                                     } else if ([resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML]) {
                                                                                                         [strongSelf showRemoveHTMLForResource:resource];
                                                                                                     } else {
                                                                                                         [strongSelf showResourceWithURL:savedResourceURL];
                                                                                                     }
                                                                                                 }
                                                                                             }];
                                                    } else {
                                                        [strongSelf showErrorWithMessage:JMCustomLocalizedString(@"savedreport.viewer.format.not.supported", nil)
                                                                              completion:^{
                                                                                  [strongSelf cancelResourceViewingAndExit:YES];
                                                                              }];
                                                    }

                                                }
                                            }];
}

- (void)showResourceWithURL:(NSURL *)url
{
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    self.isResourceLoaded = NO;

    self.resourceRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:self.resourceRequest];

}

- (void)showRemoveHTMLForResource:(JSContentResource *)resource
{
    NSString *baseURLString = [NSString stringWithFormat:@"%@/fileview/fileview/%@", self.restClient.serverProfile.serverUrl, resource.uri];

    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfFile:self.savedResourcePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];

    [self.webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString:baseURLString]];
}

- (void)showImageWithURL:(NSURL *)url
{
    [self.webView removeFromSuperview];

    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIScrollView *scrollView = [self createScrollViewWithImage:image];
    [self.view addSubview:scrollView];

    [self addConstraintsForScrollView:scrollView];
}

#pragma mark - Helpers
- (JMReportSaver *)reportSaver
{
    if (!_reportSaver) {
        _reportSaver = [JMReportSaver new];
    }
    return _reportSaver;
}
- (void)removeSavedResource
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savedResourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.savedResourcePath error:nil];
    }
}

- (void)showErrorWithMessage:(NSString *)message completion:(void(^)(void))completion
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.error"
                                                                                      message:message
                                                                            cancelButtonTitle:@"dialog.button.ok"
                                                                      cancelCompletionHandler:^(UIAlertController *controller, UIAlertAction *action) {
                                                                          if (completion) {
                                                                              completion();
                                                                          }
                                                                      }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isSupportedResource:(JSContentResource *)resource
{
    BOOL isHTML = [resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML];
    BOOL isPDF = [resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF];
    BOOL isXLS = [resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_XLS];
    BOOL isXLSX = [resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_XLSX];
    BOOL isIMG = [resource.type isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_IMG];
    return isHTML || isPDF || isXLS || isXLSX || isIMG;
}

- (UIScrollView *)createScrollViewWithImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [scrollView addSubview:imageView];
    self.imageView = imageView;

    CGFloat contentViewHeight = CGRectGetHeight(self.imageView.frame);
    CGFloat contentViewWidth = CGRectGetWidth(self.imageView.frame);

    CGFloat containerViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat containerViewWidth = CGRectGetWidth(scrollView.frame);

    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint;
    if (contentViewHeight > containerViewHeight || contentViewWidth > containerViewWidth) {
        JMLog(@"big content");
        scrollView.delegate = self;
        scrollView.clipsToBounds = YES;
        scrollView.contentSize = image.size;

        CGFloat minScaleFactor = CGRectGetWidth(self.view.frame)/image.size.width;
        scrollView.minimumZoomScale = minScaleFactor;
        scrollView.maximumZoomScale = 1;

        [scrollView setZoomScale:minScaleFactor animated:YES];

        constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:scrollView
                                                  attribute:NSLayoutAttributeTrailing
                                                 multiplier:1
                                                   constant:0];
        [scrollView addConstraint:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                  attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:scrollView
                                                  attribute:NSLayoutAttributeLeading
                                                 multiplier:1
                                                   constant:0];
        [scrollView addConstraint:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:scrollView
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1
                                                   constant:0];
        [scrollView addConstraint:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:scrollView
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1
                                                   constant:0];
        [scrollView addConstraint:constraint];
    } else {
        JMLog(@"small content");
        constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:scrollView
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1
                                                   constant:0];
        [scrollView addConstraint:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:scrollView
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1
                                                   constant:0];
        [scrollView addConstraint:constraint];
    }

    constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1
                                               constant:contentViewWidth];
    [scrollView addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1
                                               constant:contentViewHeight];
    [scrollView addConstraint:constraint];

    return scrollView;
}

- (void)addConstraintsForScrollView:(UIScrollView *)scrollView
{
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"scrollView": scrollView}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"scrollView": scrollView}]];
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
