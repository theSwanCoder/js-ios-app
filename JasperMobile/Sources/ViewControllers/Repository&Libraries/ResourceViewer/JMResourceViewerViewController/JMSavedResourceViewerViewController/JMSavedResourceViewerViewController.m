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
#import "JMExternalWindowControlsVC.h"
#import "JSReportSaver.h"
#import "JSResourceLookup+Helpers.h"
#import "JMWebViewManager.h"
#import "JMWebEnvironment.h"

@interface JMSavedResourceViewerViewController () <UIDocumentInteractionControllerDelegate, UIScrollViewDelegate, JMExternalWindowControlViewControllerDelegate>
@property (nonatomic, strong) JMSavedResources *savedReports;
@property (nonatomic, strong) NSString *changedReportName;
@property (nonatomic) UIDocumentInteractionController *documentController;
@property (nonatomic) JMExternalWindowControlsVC *controlViewController;
@property (nonatomic, strong) JSReportSaver *reportSaver;
@property (nonatomic, strong) NSURL *savedResourceURL;
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation JMSavedResourceViewerViewController
@synthesize changedReportName;


#pragma mark - Accessors
- (JMSavedResources *)savedReports
{
    if (!_savedReports) {
        _savedReports = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
    }

    return _savedReports;
}

#pragma mark - Overrided methods
- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    [self.documentController dismissMenuAnimated:YES];

    [self.reportSaver cancelSavingReport];

    if (self.savedResourceURL) {
        [self removeSavedResource];
    }

    [super cancelResourceViewingAndExit:exit];
}


- (void)startResourceViewing
{
    if ([self.resourceLookup isFile]) {
        [self showRemoteResource];
    } else {
        [self showSavedResource];
    }

    // Analytics
    NSString *label = [kJMAnalyticsResourceEventLabelSavedResource stringByAppendingFormat:@" (%@)", [self.savedReports.format uppercaseString]];
    [JMUtils logEventWithInfo:@{
                        kJMAnalyticsCategoryKey      : kJMAnalyticsResourceEventCategoryTitle,
                        kJMAnalyticsActionKey        : kJMAnalyticsResourceEventActionOpenTitle,
                        kJMAnalyticsLabelKey         : label
                }];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction action = JMMenuActionsViewAction_None;
    if ([self.resourceLookup isFile]) {
        action = [super availableActionForResource:[self resourceLookup]] | JMMenuActionsViewAction_OpenIn;
    } else {
        action = [super availableActionForResource:[self resourceLookup]] | JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete | JMMenuActionsViewAction_OpenIn ;
    }

    // TODO: We need come up with another approach to control a resource which is being presented on tv.
//    if ([self isExternalScreenAvailable]) {
//        action |= [self isContentOnTV] ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
//    }
    return action;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Rename) {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertTextDialogueControllerWithLocalizedTitle:@""
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
        NSURL *url;
        if ([self.resourceLookup isFile]) {
            url = self.savedResourceURL;
        } else {
            url = self.resourceRequest.URL;
        }
        self.documentController = [self setupDocumentControllerWithURL:url
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
- (void)showResourceWithDocumentController
{
    self.documentController = [self setupDocumentControllerWithURL:self.resourceRequest.URL
                                                     usingDelegate:self];

    BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    if (!canOpen) {
        NSString *errorMessage = JMCustomLocalizedString(@"error.openIn.message", nil);
        NSError *error = [NSError errorWithDomain:@"dialod.title.error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error completion:nil];
    }
}

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
                                                    if (error.code == JSSessionExpiredErrorCode) {
                                                        [strongSelf.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                                                            if (strongSelf.restClient.keepSession && isSessionAuthorized) {
                                                                [strongSelf showRemoteResource];
                                                            } else {
                                                                [JMUtils showLoginViewAnimated:YES completion:nil];
                                                            }
                                                        }];
                                                    } else {
                                                        [strongSelf showErrorWithMessage:error.localizedDescription
                                                                              completion:^{
                                                                                  [strongSelf cancelResourceViewingAndExit:YES];
                                                                              }];
                                                    }
                                                } else {

                                                    [strongSelf startShowLoaderWithMessage:@"status.loading" cancelBlock:^{
                                                        [strongSelf cancelResourceViewingAndExit:YES];
                                                    }];

                                                    NSString *resourcePath = [NSString stringWithFormat:@"%@/rest_v2/resources%@", strongSelf.restClient.serverProfile.serverUrl, resource.uri];
                                                    __typeof(self) weakSelf = strongSelf;
                                                    JSReport *report = [JSReport reportWithResourceLookup:strongSelf.resourceLookup];
                                                    strongSelf.reportSaver = [[JSReportSaver alloc] initWithReport:report restClient:strongSelf.restClient];
                                                    [strongSelf.reportSaver downloadResourceFromURLString:resourcePath
                                                                                         completion:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                                             __typeof(self) strongSelf = weakSelf;
                                                                                             [strongSelf stopShowLoader];
                                                                                             if (error) {
                                                                                                 [strongSelf showErrorWithMessage:error.localizedDescription
                                                                                                                       completion:^{
                                                                                                                           [strongSelf cancelResourceViewingAndExit:YES];
                                                                                                                       }];
                                                                                             } else {
                                                                                                 strongSelf.savedResourceURL = location;

                                                                                                 if ([strongSelf isSupportedResource:resource]) {
                                                                                                     if ([resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_IMG]) {
                                                                                                         [strongSelf showImageWithURL:strongSelf.savedResourceURL];
                                                                                                     } else if ([resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_HTML]) {
                                                                                                         NSURL *fileURL = [strongSelf updateFormatForURL:strongSelf.savedResourceURL withFormat:kJS_CONTENT_TYPE_HTML];
                                                                                                         [strongSelf moveResourceFromPath:strongSelf.savedResourceURL.path
                                                                                                                                   toPath:fileURL.path];
                                                                                                         strongSelf.savedResourceURL = fileURL;
                                                                                                         [strongSelf showRemoveHTMLForResource:resource];
                                                                                                     } else {
                                                                                                         NSURL *fileURL = [strongSelf updateFormatForURL:strongSelf.savedResourceURL withFormat:resource.fileFormat];
                                                                                                         [strongSelf moveResourceFromPath:strongSelf.savedResourceURL.path
                                                                                                                                   toPath:fileURL.path];
                                                                                                         strongSelf.savedResourceURL = fileURL;
                                                                                                         [strongSelf showResourceWithURL:fileURL];
                                                                                                     }
                                                                                                 } else {
                                                                                                     // TODO: add showing with ...
//                                                                                                     strongSelf.resourceRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:outputResourcePath]];
//                                                                                                     [strongSelf showResourceWithDocumentController];
                                                                                                     [strongSelf showErrorWithMessage:JMCustomLocalizedString(@"savedreport.viewer.format.not.supported", nil)
                                                                                                                           completion:^{
                                                                                                                               [strongSelf cancelResourceViewingAndExit:YES];
                                                                                                                           }];
                                                                                                 }
                                                                                             }
                                                                                         }];
                                                }
                                            }];
}

- (void)showResourceWithURL:(NSURL *)url
{
    self.isResourceLoaded = NO;

    // TODO: do we need this?
//    self.resourceRequest = [NSURLRequest requestWithURL:url];

    JMWebEnvironment *webEnvironment = [[JMWebViewManager sharedInstance] webEnvironmentForId:kJMResourceViewerWebEnvironmentIdentifier];
    [webEnvironment loadLocalFileFromURL:url];
}

- (void)showRemoveHTMLForResource:(JSContentResource *)resource
{
    NSString *baseURLString = [NSString stringWithFormat:@"%@/fileview/fileview/%@", self.restClient.serverProfile.serverUrl, resource.uri];

    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfFile:self.savedResourceURL.path
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
    JMWebEnvironment *webEnvironment = [[JMWebViewManager sharedInstance] webEnvironmentForId:kJMResourceViewerWebEnvironmentIdentifier];
    [webEnvironment loadHTML:htmlString
                     baseURL:[NSURL URLWithString:baseURLString]
                  completion:nil];
}

- (void)showImageWithURL:(NSURL *)url
{
    [[self resourceView] removeFromSuperview];

    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIScrollView *scrollView = [self createScrollViewWithImage:image];
    [self.view addSubview:scrollView];

    [self addConstraintsForScrollView:scrollView];
}

#pragma mark - Helpers
- (void)removeSavedResource
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savedResourceURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.savedResourceURL.path error:nil];
    }
    _savedResourceURL = nil;
}

- (NSError *)moveResourceFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:fromPath
                                            toPath:toPath
                                             error:&error];
    return error;
}

- (NSURL *)updateFormatForURL:(NSURL *)fromURL withFormat:(NSString *)newFormat
{
    NSString *fullPathWithoutFormat = [fromURL.path stringByDeletingPathExtension];
    NSString *fullPathWithNewFormat = [fullPathWithoutFormat stringByAppendingPathExtension:newFormat];
    fullPathWithNewFormat = [NSString stringWithFormat:@"file://%@", fullPathWithNewFormat];
    NSURL *URLWithFormat = [NSURL URLWithString:fullPathWithNewFormat];
    JMLog(@"%@", URLWithFormat);
    return URLWithFormat;
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
    BOOL isHTML = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_HTML];
    BOOL isPDF = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_PDF];
    BOOL isXLS = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_XLS];
    BOOL isXLSX = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_XLSX];
    BOOL isIMG = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_IMG];
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
