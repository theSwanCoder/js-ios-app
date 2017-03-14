/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMContentResourceViewerVC.h"
#import "JMContentResourceViewerConfigurator.h"
#import "JMContentResourceViewerStateManager.h"
#import "JMContentResourceLoader.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JasperMobileAppDelegate.h"
#import "JMWebEnvironment.h"
#import "JMContentResourceViewerExternalScreenManager.h"
#import "JMSavedResources+Helpers.h"
#import "PopoverView.h"

#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerSessionManager.h"
#import "JMResourceViewerFavoritesHelper.h"

@interface JMContentResourceViewerVC () <JMResourceViewerStateManagerDelegate>
@property (nonatomic) UIDocumentInteractionController *documentController;

@end

@implementation JMContentResourceViewerVC
@synthesize resource;

#pragma mark - Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController LifeCycle

- (void)loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"JMBaseResourceView"
                                               owner:self
                                             options:nil] firstObject];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.resource.resourceLookup.label;
    
    
    [self.configurator setup];
    [self setupSessionManager];
    [self setupStateManager];
//    [self setupExternalScreenManager];
    
    [self startResourceViewing];
}

#pragma mark - Setups

- (void)setupStateManager
{
    [self stateManager].controller = self;
    [self stateManager].delegate = self;
    [[self stateManager] setupPageForState:JMResourceViewerStateInitial];
}

- (void)setupSessionManager
{
    self.configurator.sessionManager.controller = self;
    
    __weak typeof(self) weakSelf = self;
    self.configurator.sessionManager.cleanAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.configurator reset];
    };
    self.configurator.sessionManager.executeAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.contentResourceLoader cancel];

        [strongSelf.configurator setup];
        [strongSelf setupStateManager];
        
        [strongSelf startResourceViewing];
    };
    self.configurator.sessionManager.exitAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf exitAction];
    };
}


- (void)startResourceViewing
{
    [[self stateManager] setupPageForState:JMResourceViewerStateLoading];

    __weak typeof(self) weakSelf = self;
    [[self contentResourceLoader] loadContentResourceForResource:self.resource completion:^(NSURL *baseURL, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf handleError:error];
        } else {
            [strongSelf.webEnvironment loadLocalFileFromURL:strongSelf.contentResourceURL
                                                 fileFormat:strongSelf.contentResource.fileFormat
                                                    baseURL:baseURL];
            [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
        }
    }];
    
    // Analytics
    NSString *label = [kJMAnalyticsResourceLabelSavedResource stringByAppendingFormat:@" (%@)", [self.contentResource.fileFormat uppercaseString]];
    [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                                                                     kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
                                                                     kJMAnalyticsActionKey   : kJMAnalyticsEventActionOpen,
                                                                     kJMAnalyticsLabelKey    : label
                                                                     }];
}

#pragma mark - Handler Errors

- (void)handleError:(NSError *)error
{
    [[self stateManager] setupPageForState:JMResourceViewerStateResourceFailed];
    
    switch (error.code) {
        case JSReportLoaderErrorTypeSessionDidExpired: {
            [self.configurator.sessionManager handleSessionDidExpire];
            break;
        }
        case JSReportLoaderErrorTypeSessionDidRestore: {
            [self.configurator.sessionManager handleSessionDidRestore];
            break;
        }
        case JSReportLoaderErrorTypeUndefined: {
            [JMUtils presentAlertControllerWithError:error
                                          completion:nil];
            break;
        }
        default: {
            __weak typeof(self) weakSelf = self;
            [JMUtils presentAlertControllerWithError:error completion:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf exitAction];
            }];
            break;
        }
    }
}


#pragma mark - Helpers

- (JMWebEnvironment *)webEnvironment
{
    return self.configurator.webEnvironment;
}

- (JSContentResource *)contentResource
{
    return [self contentResourceLoader].contentResource;
}

- (NSURL *)contentResourceURL
{
    return [self contentResourceLoader].contentResourceURL;
}

- (JMSavedResources *)savedResource
{
    return [self contentResourceLoader].savedResource;
}

- (JMContentResourceViewerStateManager *)stateManager
{
    return (JMContentResourceViewerStateManager *)self.configurator.stateManager;
}

- (JMContentResourceLoader *)contentResourceLoader
{
    return (JMContentResourceLoader *)self.configurator.contentResourceLoader;
}

- (JMContentResourceViewerExternalScreenManager *)externalScreenManager
{
    return (JMContentResourceViewerExternalScreenManager *)self.configurator.externalScreenManager;
}

#pragma mark - JMResourceViewerProtocol
- (UIView *)contentView
{
    return [self webEnvironment].webView;
}

#pragma mark - JMResourceViewerStateManagerDelegate

- (void)stateManagerWillExit:(JMResourceViewerStateManager *)stateManager
{
    [self exitAction];
}

- (void)stateManagerWillCancel:(JMResourceViewerStateManager *)stateManager
{
    [self exitAction];
}

#pragma mark - Actions
- (void)exitAction
{
    [self cancelAction];
    [[self stateManager] setupPageForState:JMResourceViewerStateDestroy];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [[self contentResourceLoader] cancel];
    [self.webEnvironment clean];
    [self.documentController dismissMenuAnimated:YES];
}


#pragma mark - JMMenuActionsViewProtocol
- (JMMenuActionsViewAction)availableActions
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    availableAction |= JMMenuActionsViewAction_Share | JMMenuActionsViewAction_OpenIn;
    
    if (![[self stateManager].favoritesHelper shouldShowFavoriteBarButton]) {
        availableAction |= ([[self stateManager].favoritesHelper isResourceInFavorites] ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite);
    }
    
    BOOL isSavedResource = (self.resource.type == JMResourceTypeSavedReport) || (self.resource.type == JMResourceTypeSavedDashboard);
    BOOL isFile = self.resource.type == JMResourceTypeFile;
    if ( !(isSavedResource || isFile) ) {
        availableAction |= JMMenuActionsViewAction_Print;
    }

    if (!isFile) {
        availableAction |= JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete ;
    }
    
    JasperMobileAppDelegate *appDelegate = (JasperMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDelegate isExternalScreenAvailable]) {
        // TODO: extend by considering other states
        availableAction |= ([self stateManager].state == JMResourceViewerStateResourceOnWExternalWindow) ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }
    return availableAction;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [view.popoverView dismiss];
    
    switch (action) {
        case JMMenuActionsViewAction_MakeFavorite:
        case JMMenuActionsViewAction_MakeUnFavorite:
            // TODO: find other solution
            [[self stateManager] updateFavoriteState];
            break;
        case JMMenuActionsViewAction_Info: {
            self.configurator.infoPageManager.controller = self;
            [self.configurator.infoPageManager showInfoPageForResource:self.resource];
            break;
        }
        case JMMenuActionsViewAction_Print: {
            [self printContentResource];
            break;
        }
        case JMMenuActionsViewAction_Rename: {
            [self renameContentResource];
            break;
        }
        case JMMenuActionsViewAction_Delete: {
            [self deleteContentResource];
            break;
        }
        case JMMenuActionsViewAction_OpenIn: {
            [self openInContentResource];
            break;
        }
        case JMMenuActionsViewAction_Share:{
            self.configurator.shareManager.controller = self;
            [self.configurator.shareManager shareContentView:[self contentView]];
            break;
        }
        case JMMenuActionsViewAction_ShowExternalDisplay: {
            [self showOnTV];
            break;
        }
        case JMMenuActionsViewAction_HideExternalDisplay: {
            [self switchFromTV];
            break;
        }
        default:{break;}
    }
}

- (void)printContentResource
{
    self.configurator.printManager.controller = self;
    
    __weak typeof(self) weakSelf = self;
    self.configurator.printManager.userPrepareBlock = (id)^{
        __strong typeof(self) strongSelf = weakSelf;
        return strongSelf.contentResourceURL;
    };
    [self.configurator.printManager printResource:self.resource
                             prepearingCompletion:nil
                                  printCompletion:nil];
}

- (void)renameContentResource
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertTextDialogueControllerWithLocalizedTitle:@""
                                                                                                  message:nil
                                                                            textFieldConfigurationHandler:^(UITextField * _Nonnull textField) {
                                                                                __strong typeof(self) strongSelf = weakSelf;
                                                                                textField.placeholder = JMLocalizedString(@"savedreport_viewer_modify_reportname");
                                                                                textField.text = [strongSelf.contentResource.label copy];
                                                                            } textValidationHandler:^NSString * _Nonnull(NSString * _Nullable text) {
                                                                                NSString *errorMessage = nil;
                                                                                __strong typeof(self) strongSelf = weakSelf;
                                                                                if (strongSelf) {
                                                                                    [JMUtils validateResourceName:text errorMessage:&errorMessage];
                                                                                    if (!errorMessage && ![JMSavedResources isAvailableResourceName:text format:strongSelf.contentResource.fileFormat resourceType:strongSelf.resource.type]) {
                                                                                        errorMessage = JMLocalizedString(@"resource_viewer_save_name_errmsg_notunique");
                                                                                    }
                                                                                }
                                                                                return errorMessage;
                                                                            } textEditCompletionHandler:^(NSString * _Nullable text) {
                                                                                __strong typeof(self) strongSelf = weakSelf;
                                                                                if ([strongSelf.savedResource renameResourceTo:text]) {
                                                                                    strongSelf.title = text;
                                                                                    strongSelf.resource = [strongSelf.savedResource wrapperFromSavedResources];
                                                                                }
                                                                            }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteContentResource
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_confirmation"
                                                                                      message:@"savedreport_viewer_delete_confirmation_message"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:nil];
    __weak typeof(self) weakSelf = self;
    [alertController addActionWithLocalizedTitle:@"dialog_button_ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;

        [strongSelf.savedResource removeResource];

        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(resourceViewer:didDeleteResource:)]) {
            [self cancelAction];
            [strongSelf.delegate resourceViewer:strongSelf didDeleteResource:strongSelf.resource];
        } else {
            [self exitAction];
        }
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openInContentResource
{
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL: self.contentResourceURL];
    BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    if (!canOpen) {
        NSString *errorMessage = JMLocalizedString(@"error_openIn_message");
        NSError *error = [NSError errorWithDomain:@"dialod_title_error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error completion:nil];
    }
}

#pragma mark - Work with external window
- (void)showOnTV
{
    [[self stateManager] setupPageForState:JMResourceViewerStateResourceOnWExternalWindow];
    [[self externalScreenManager] showContentOnTV];
}

- (void)switchFromTV
{
    [[self stateManager] setupPageForState:JMResourceViewerStateResourceReady];
    [[self externalScreenManager] backContentOnDevice];
}

#pragma mark - Rotation
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:nil completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        [[self stateManager] updatePageForChangingSizeClass];
    }];
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - Analytics

- (NSString *)additionalsToScreenName
{
    NSString *additinalString = @"";
    if (self.resource.type == JMResourceTypeFile) {
        additinalString = [NSString stringWithFormat:@" (Content Resource: %@)", [self.contentResource.fileFormat uppercaseString]];
    } else {
        additinalString = [NSString stringWithFormat:@" (Exported Resource: %@)", [self.contentResource.fileFormat uppercaseString]];
    }
    return additinalString;
}

@end
