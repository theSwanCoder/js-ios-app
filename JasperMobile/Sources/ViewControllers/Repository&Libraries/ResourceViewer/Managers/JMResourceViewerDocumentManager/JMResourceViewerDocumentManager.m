/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerDocumentManager.h"
#import "JMLocalization.h"
#import "JMUtils.h"

@interface JMResourceViewerDocumentManager() <UIDocumentInteractionControllerDelegate>
@property (nonatomic) UIDocumentInteractionController *documentController;
@end

@implementation JMResourceViewerDocumentManager

#pragma mark - Public API
- (void)showOpenInMenuForResourceWithURL:(NSURL *)URL
{
    NSAssert(self.controller != nil, @"Controller is nil");
    NSAssert(URL != nil, @"document URL is nil");
    self.documentController = [self setupDocumentControllerWithURL:URL
                                                     usingDelegate:self];

    BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.controller.navigationItem.rightBarButtonItem
                                                                      animated:YES];
    if (!canOpen) {
        NSString *errorMessage = JMLocalizedString(@"error_openIn_message");
        NSError *error = [NSError errorWithDomain:@"dialod_title_error"
                                             code:NSNotFound
                                         userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error
                                      completion:nil];
    }
}

#pragma mark - Helpers
- (UIDocumentInteractionController *) setupDocumentControllerWithURL: (NSURL *)URL
                                                       usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: URL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

#pragma mark - UIDocumentInteractionControllerDelegate

@end
