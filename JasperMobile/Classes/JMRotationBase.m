//
//  JMRotationUtilities.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/31/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMRotationBase.h"
#import "JMRotatable.h"
#import <Objection-iOS/Objection.h>

@implementation JMRotationBase

#pragma mark - Rotation base implementation

+ (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self rotation] preferredInterfaceOrientationForPresentation];
}

+ (NSUInteger)supportedInterfaceOrientations
{
    return [[self rotation] supportedInterfaceOrientations];
}

+ (BOOL)shouldAutorotate
{
    return [[self rotation] shouldAutorotate];
}

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[self rotation] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Private

+ (id <JMRotatable>)rotation
{
    return [[JSObjection defaultInjector] getObject:@protocol(JMRotatable)];
}

@end
