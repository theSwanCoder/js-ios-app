//
// Created by Aleksandr Dakhno on 1/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//


@interface JMDashboardInputControlsVC : UIViewController
@property (nonatomic, strong) NSArray <JSInputControlDescriptor *>*inputControls;
@property (nonatomic, copy) void(^exitBlock)(NSArray <JSInputControlDescriptor *>*changedInputControls);
@end