/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

#import <UIKit/UIKit.h>
#import "JMResourceViewerToolbarsHelper.h"

typedef NS_ENUM(NSInteger, JMResourceViewerState) {
    JMResourceViewerStateInitial,
    JMResourceViewerStateLoading,
    JMResourceViewerStateLoadingForPrint,
    JMResourceViewerStateResourceReady,
    JMResourceViewerStateResourceFailed,
    JMResourceViewerStateResourceNotExist,
    JMResourceViewerStateNestedResource,
    JMResourceViewerStateResourceOnWExternalWindow,
    JMResourceViewerStateMaximizedDashlet,
    JMResourceViewerStateDestroy,
    JMResourceViewerStateNotVisible
};

@class JMResourceViewerMenuHelper;
@class JMResourceViewerFavoritesHelper;

@protocol JMResourceViewerStateManagerDelegate;
@protocol JMMenuActionsViewDelegate;
@protocol JMResourceClientHolder;
@protocol JMResourceViewerProtocol;
@protocol JMMenuActionsViewProtocol;

@interface JMResourceViewerStateManager : NSObject
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *warningsView;
@property (nonatomic, strong) JMResourceViewerToolbarsHelper *toolbarsHelper;
@property (nonatomic, strong) JMResourceViewerFavoritesHelper *favoritesHelper;
@property (nonatomic, assign) BOOL needFavoriteButton;
@property (nonatomic, strong) JMResourceViewerMenuHelper *menuHelper;
@property (nonatomic, copy) void(^openDocumentActionBlock)(void);
@property (nonatomic, weak) UIViewController <JMResourceClientHolder, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol, JMResourceViewerProtocol>*controller;
@property (nonatomic, weak) id <JMResourceViewerStateManagerDelegate> delegate;
@property (nonatomic, assign, readonly) JMResourceViewerState state;
- (void)setupPageForState:(JMResourceViewerState)state NS_REQUIRES_SUPER;

- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState;
- (void)updatePageForChangingSizeClass;
- (void)updateFavoriteState;
- (void)reset;
- (void)initialSetupNavigationItems;
- (void)setupNavigationItems;
- (void)setupNavigationItemsForNestedResource;
- (void)removeMenuBarButton;
- (UIBarButtonItem *)backBarButtonWithTitle:(NSString *)title action:(SEL)action;
- (void)showMainView;
- (void)hideMainView;
- (void)showProgress;
- (void)hideProgress;
- (void)showResourceNotExistView;
- (void)hideResourceNotExistView;

@end

@protocol JMResourceViewerStateManagerDelegate <NSObject>
@optional
- (void)stateManagerWillExit:(JMResourceViewerStateManager *)stateManager;
- (void)stateManagerWillCancel:(JMResourceViewerStateManager *)stateManager;
- (void)stateManagerWillBackFromNestedResource:(JMResourceViewerStateManager *)stateManager;
@end
