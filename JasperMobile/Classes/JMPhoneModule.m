//
//  JMPhoneRotationModule.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMPhoneModule.h"
#import "JMPhoneRotation.h"

@implementation JMPhoneModule

- (void)configure {
    [super configure];
    [self bind:[[JMPhoneRotation alloc] init] toProtocol:@protocol(JMRotatable)];
}

@end
