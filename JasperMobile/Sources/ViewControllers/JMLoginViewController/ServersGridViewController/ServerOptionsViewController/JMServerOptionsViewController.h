/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>
#import "JMServerProfile.h"
#import "JMEditabledViewController.h"

@interface JMServerOptionsViewController : JMEditabledViewController
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, retain) JMServerProfile *serverProfile;
@property (nonatomic, copy) void(^exitBlock)(void);
- (void)cancel;
@end
