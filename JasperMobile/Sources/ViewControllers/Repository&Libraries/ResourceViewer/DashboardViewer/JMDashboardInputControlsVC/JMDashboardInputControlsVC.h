//
// Created by Aleksandr Dakhno on 1/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//


#import "JMEditabledViewController.h"

@class JMDashboard;

@interface JMDashboardInputControlsVC : JMEditabledViewController
@property (nonatomic, strong) JMDashboard *dashboard;
@property (nonatomic, copy) void(^exitBlock)(BOOL inputControlsDidChanged);
@end