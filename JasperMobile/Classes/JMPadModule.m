//
//  JMPadRotationModule.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMPadModule.h"
#import "JMPadRotation.h"

@implementation JMPadModule

- (void)configure
{
    [super configure];
    [self bind:[[JMPadRotation alloc] init] toProtocol:@protocol(JMRotatable)];
}

@end
