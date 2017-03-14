/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Olexandr Dakhno odahno@tibco.com
 @since 2.3
 */

@import UIKit;
#import "JaspersoftSDK.h"
@protocol JMExternalWindowDashboardControlsVCDelegate;

@interface JMExternalWindowDashboardControlsVC : UIViewController
@property (nonatomic, copy) NSArray <JSDashboardComponent *>* components;
@property (nonatomic, weak) NSObject <JMExternalWindowDashboardControlsVCDelegate> *delegate;
- (void)markComponentAsMinimized:(JSDashboardComponent *)component;
@end


@protocol JMExternalWindowDashboardControlsVCDelegate
@optional
- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMaximizeDashlet:(JSDashboardComponent *)dashlet;
- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMinimizeDashlet:(JSDashboardComponent *)dashlet;
@end
