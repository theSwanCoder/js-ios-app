//
//  JMServerOptionsViewController.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMServerProfile.h"
#import "JMEditabledViewController.h"

@interface JMServerOptionsViewController : JMEditabledViewController

@property (nonatomic, retain) JMServerProfile *serverProfile;
@end
