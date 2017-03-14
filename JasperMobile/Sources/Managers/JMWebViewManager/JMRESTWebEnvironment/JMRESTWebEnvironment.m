/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMRESTWebEnvironment.h"
#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptRequestTask.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"

@implementation JMRESTWebEnvironment

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

@end
