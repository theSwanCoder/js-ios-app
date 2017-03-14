/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMContentResourceViewerStateManager.h"
#import "JMContentResourceViewerVC.h"
#import "JMResource.h"
#import "JMResourceViewerMenuHelper.h"


@implementation JMContentResourceViewerStateManager
#pragma mark - Public API

- (void)setupPageForState:(JMResourceViewerState)state
{
    [super setupPageForState:state];
    
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
}

#pragma mark - Helpers

- (void)setupNavigationItemForState:(JMResourceViewerState)state
{
    self.needFavoriteButton = YES;
    switch (state) {
        case JMResourceViewerStateInitial: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self setupNavigationItems];
            break;
        }
        case JMResourceViewerStateDestroy:
        case JMResourceViewerStateMaximizedDashlet:
        case JMResourceViewerStateLoading:
        case JMResourceViewerStateLoadingForPrint:
        case JMResourceViewerStateResourceFailed:
        case JMResourceViewerStateResourceNotExist:
        case JMResourceViewerStateNotVisible:
        case JMResourceViewerStateNestedResource:
        case JMResourceViewerStateResourceOnWExternalWindow: {
            break;
        }
    }
}

- (void)setupMainViewForState:(JMResourceViewerState)state
{
    switch (state) {
        case JMResourceViewerStateInitial: {
            self.controller.title = self.controller.resource.resourceLookup.label;
            [self showResourceNotExistView];
            [self hideProgress];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateLoading: {
            [self showProgress];
            [self hideResourceNotExistView];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self showMainView];
            [self hideProgress];
            [self hideResourceNotExistView];
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateDestroy: {
            [self reset];
            break;
        }
        case JMResourceViewerStateMaximizedDashlet:
        case JMResourceViewerStateLoadingForPrint:
        case JMResourceViewerStateResourceNotExist:
        case JMResourceViewerStateResourceOnWExternalWindow:
        case JMResourceViewerStateNotVisible:
        case JMResourceViewerStateNestedResource: {
            break;
        }
    }
}

@end
