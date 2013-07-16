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
    [self bindClass:[JSProfile class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSRESTReport class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSRESTResource class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSConstants class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[NSManagedObjectContext class] inScope:JSObjectionScopeSingleton];
    [self bind:[[JSRESTReport alloc] init] toClass:[JSRESTReport class]];
    [self bind:[[JSRESTResource alloc] init] toClass:[JSRESTResource class]];
    [self bind:[[JSConstants alloc] init] toClass:[JSConstants class]];
    [self bind:self.managedObjectContext toClass:[NSManagedObjectContext class]];
}

@end
