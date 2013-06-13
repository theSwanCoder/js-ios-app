//
//  JMRotationUtilities.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/31/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Provides general solution for rotation. Works for iPhone and iPad (iOS 5.0 - 6.1)
*/
@interface JMRotationBase : NSObject

+ (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
+ (NSUInteger)supportedInterfaceOrientations;
+ (BOOL)shouldAutorotate;
+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

#define inject_default_rotation() \
    - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { \
        return [JMRotationBase preferredInterfaceOrientationForPresentation]; \
    } \
    - (NSUInteger)supportedInterfaceOrientations { \
        return [JMRotationBase supportedInterfaceOrientations]; \
    } \
    - (BOOL)shouldAutorotate { \
        return [JMRotationBase shouldAutorotate]; \
    } \
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { \
        return [JMRotationBase shouldAutorotateToInterfaceOrientation:interfaceOrientation]; \
    }