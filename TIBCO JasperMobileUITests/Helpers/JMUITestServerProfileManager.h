//
// Created by Aleksandr Dakhno on 11/3/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMUITestServerProfile;

@interface JMUITestServerProfileManager : NSObject
@property (nonatomic, strong) JMUITestServerProfile *testProfile;
+ (instancetype)sharedManager;
@end