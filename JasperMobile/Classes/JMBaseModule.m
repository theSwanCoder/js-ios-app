//
//  JasperMobileModule.m
//  JasperMobile
//
//  Created by Vlad on 5/26/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMBaseModule.h"
#import "JMRotatable.h"
#import "JMPhoneRotation.h"
#import "JMPadRotation.h"
#import <CoreData/CoreData.h>

@implementation JMBaseModule

- (void)configure
{
    // Set visibility scope
    [self bindClass:[JSProfile class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSRESTReport class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSRESTResource class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSConstants class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[NSManagedObjectContext class] inScope:JSObjectionScopeSingleton];
    
    JSRESTReport *reportClient = [[JSRESTReport alloc] init];
    JSRESTResource *resourceClient = [[JSRESTResource alloc] init];
    // Set "continue request" as a default request background policy
    reportClient.requestBackgroundPolicy = JSRequestBackgroundPolicyContinue;
    resourceClient.requestBackgroundPolicy = JSRequestBackgroundPolicyContinue;
    
    [self bind:reportClient toClass:[JSRESTReport class]];
    [self bind:resourceClient toClass:[JSRESTResource class]];
    [self bind:[[JSConstants alloc] init] toClass:[JSConstants class]];
    [self bind:self.managedObjectContext toClass:[NSManagedObjectContext class]];
}

@end
