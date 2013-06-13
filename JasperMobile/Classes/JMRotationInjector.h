//
//  JMRotationUtilities.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/31/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMRotationInjector : NSObject

+ (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
+ (NSUInteger)supportedInterfaceOrientations;
+ (BOOL)shouldAutorotate;
+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

// Default implementation for rotation
UIInterfaceOrientation JMPreferredInterfaceOrientationForPresentation();
NSUInteger JMSupportedInterfaceOrientations();
BOOL JMShouldAutorotate();
BOOL JMShouldAutorotateToInterfaceOrientation(UIInterfaceOrientation interfaceOrientation);

#define inject_default_rotation() \
    - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { \
        return [JMRotationInjector preferredInterfaceOrientationForPresentation]; \
    } \
    - (NSUInteger)supportedInterfaceOrientations { \
        return [JMRotationInjector supportedInterfaceOrientations]; \
    } \
    - (BOOL)shouldAutorotate { \
        return [JMRotationInjector shouldAutorotate]; \
    } \
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { \
        return [JMRotationInjector shouldAutorotateToInterfaceOrientation:interfaceOrientation]; \
    }


#define inject_default_rotation_Second_Example() \
    - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { \
        return JMPreferredInterfaceOrientationForPresentation(); \
    } \
    - (NSUInteger)supportedInterfaceOrientations { \
        return JMSupportedInterfaceOrientations(); \
    } \
    - (BOOL)shouldAutorotate { \
        return JMShouldAutorotate(); \
    } \
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { \
        return JMShouldAutorotateToInterfaceOrientation(interfaceOrientation); \
    }