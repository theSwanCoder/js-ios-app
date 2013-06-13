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

@interface JMBaseModule()
@property (nonatomic, strong) JSProfile *profile;
@end

@implementation JMBaseModule

- (id)initWithProfile:(JSProfile *)profile
{
    if (self = [self init]) {
        self.profile = profile;
    }
    
    return self;
}

- (void)configure
{
    [self bindClass:[JSProfile class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSRESTReport class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSRESTResource class] inScope:JSObjectionScopeSingleton];
    [self bindClass:[JSConstants class] inScope:JSObjectionScopeSingleton];
    [self bind:self.profile toClass:[JSProfile class]];
    [self bind:[[JSRESTReport alloc] initWithProfile:self.profile] toClass:[JSRESTReport class]];
    [self bind:[[JSRESTResource alloc] initWithProfile:self.profile] toClass:[JSRESTResource class]];
    [self bind:[[JSConstants alloc] init] toClass:[JSConstants class]];
}

@end
