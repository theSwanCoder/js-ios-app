/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>

@class JMUITestServerProfile;

@interface JMUITestServerProfileManager : NSObject
@property (nonatomic, strong) JMUITestServerProfile *testProfile;
+ (instancetype)sharedManager;
- (void)switchToDemoProfile;
@end
