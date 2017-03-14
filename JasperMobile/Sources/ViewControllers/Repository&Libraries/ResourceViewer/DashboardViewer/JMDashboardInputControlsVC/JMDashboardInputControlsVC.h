/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

#import "JMEditabledViewController.h"

@class JMDashboard;

@interface JMDashboardInputControlsVC : JMEditabledViewController
@property (nonatomic, strong) JMDashboard *dashboard;
@property (nonatomic, copy) void(^exitBlock)(BOOL inputControlsDidChanged);
@end
