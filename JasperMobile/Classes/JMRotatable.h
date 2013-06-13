//
//  JMRotatable.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Implementations of the `JMRotatable` protocol provide general rotation support for iOS 5 and 6
 */
@protocol JMRotatable <NSObject>

@required

// Returns the interface orientation to use when presenting the view controller;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

// Return list of supported orientations.
- (NSUInteger)supportedInterfaceOrientations;

// Determine iOS 6 Autorotation
- (BOOL)shouldAutorotate;

// handle iOS 5 Orientation as normal
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
