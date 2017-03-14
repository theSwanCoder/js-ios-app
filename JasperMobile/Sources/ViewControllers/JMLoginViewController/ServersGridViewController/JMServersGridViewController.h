/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;
#import "JMBaseViewController.h"
@class JMServerProfile;

@protocol JMServersGridViewControllerDelegate <NSObject>

@optional
- (void)serverGridControllerDidSelectProfile:(JMServerProfile *)serverProfile;

@end

@interface JMServersGridViewController : JMBaseViewController
@property (nonatomic, weak) IBOutlet id <JMServersGridViewControllerDelegate> delegate;


@end
