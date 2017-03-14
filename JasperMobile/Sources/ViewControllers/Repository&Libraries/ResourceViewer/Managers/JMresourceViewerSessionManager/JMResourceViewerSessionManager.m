/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerSessionManager.h"
#import "JMReportViewerVC.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "UIAlertController+Additions.h"

@implementation JMResourceViewerSessionManager

#pragma mark - Public API

- (void)handleSessionDidExpire
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (self.controller.restClient.serverProfile.keepSession) {
        if (self.cleanAction) {
            self.cleanAction();
        }
        __weak typeof(self) weakSelf = self;
        [self.restClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult *_Nullable result) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!result.error) {
                [strongSelf showSessionDidExpireAlert];
            } else {
                __weak typeof(self) weakSelf = strongSelf;
                [JMUtils showLoginViewAnimated:YES completion:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf.exitAction) {
                        strongSelf.exitAction();
                    }
                }];
            }
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [JMUtils showLoginViewAnimated:YES completion:^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf.exitAction) {
                strongSelf.exitAction();
            }
        }];
    }
}

- (void)handleSessionDidRestore
{
    [self showSessionDidRestoreAlert];
}


#pragma mark - Helpers

- (void)showSessionDidExpireAlert
{
    __weak typeof(self) weakSelf = self;
    // TODO: add translations
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Session was expired"
                                                                                      message:@"Reload?"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          __strong typeof(self) strongSelf = weakSelf;
                                                                          if (strongSelf.exitAction) {
                                                                              strongSelf.exitAction();
                                                                          }
                                                                      }];
    [alertController addActionWithLocalizedTitle:@"dialog_button_reload"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             if (strongSelf.executeAction) {
                                                 strongSelf.executeAction();
                                             }
                                         }];
    [self.controller presentViewController:alertController
                                  animated:YES
                                completion:nil];
}

- (void)showSessionDidRestoreAlert
{
    __weak typeof(self) weakSelf = self;
    // TODO: add translations
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Session was restored"
                                                                                      message:@"Reload?"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          __strong typeof(self) strongSelf = weakSelf;
                                                                          // back to collection view
                                                                          if (strongSelf.exitAction) {
                                                                              strongSelf.exitAction();
                                                                          }
                                                                      }];
    [alertController addActionWithLocalizedTitle:@"dialog_button_reload"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             if (strongSelf.executeAction) {
                                                 strongSelf.executeAction();
                                             }
                                         }];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

@end
