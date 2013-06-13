//
//  JMViewControllerHelper.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMViewControllerHelper.h"
#import <Objection-iOS/Objection.h>

@implementation JMViewControllerHelper

+ (void)awakeFromNibForResourceViewController:(UIViewController <JMResourceClientHolder>*)viewController
{
    [[JSObjection defaultInjector] injectDependencies:viewController];
    viewController.navigationItem.title = viewController.resourceDescriptor.label ?: viewController.resourceClient.serverProfile.alias;
}

@end
