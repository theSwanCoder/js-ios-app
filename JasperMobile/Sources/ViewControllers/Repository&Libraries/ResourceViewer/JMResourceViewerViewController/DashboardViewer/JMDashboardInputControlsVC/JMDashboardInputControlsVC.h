//
// Created by Aleksandr Dakhno on 1/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//


@class JMDashboard;

@interface JMDashboardInputControlsVC : UIViewController
@property (nonatomic, strong) JMDashboard *dashboard;
@property (nonatomic, copy) void(^exitBlock)(NSArray <JSInputControlDescriptor *>*changedInputControls);
@end