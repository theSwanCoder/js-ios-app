/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import "JMPopupView.h"

typedef void(^JMCancelRequestBlock)(void);

@interface JMCancelRequestPopup : JMPopupView

+ (void) presentWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock;
+ (void)presentWithMessage:(NSString *)message;
+ (void) dismiss;

@end

