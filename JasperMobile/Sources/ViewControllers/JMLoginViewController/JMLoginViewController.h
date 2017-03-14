/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMBaseViewController.h"

typedef void(^LoginCompletionBlock)(void);

@interface JMLoginViewController : JMBaseViewController

@property (nonatomic, copy) LoginCompletionBlock completion;
@property (nonatomic) BOOL showForRestoreSession;

@end
