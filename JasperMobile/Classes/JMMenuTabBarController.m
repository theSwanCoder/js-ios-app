//
//  JMTabBarController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMMenuTabBarController.h"
#import "JMRotatable.h"
#import "JMRotationBase.h"
#import <Objection-iOS/Objection.h>

@implementation JMMenuTabBarController
inject_default_rotation()

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[JSObjection defaultInjector] injectDependencies:self];
}

@end
