/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import UIKit;
@class JMResource;

@interface JMResourceViewerPrintManager : NSObject
@property (nonatomic, weak, nullable) UIViewController * controller;
@property (nonatomic, copy, nullable) id __nullable (^userPrepareBlock)(void);
- (void)printResource:(JMResource * __nonnull)resource
 prepearingCompletion:(void(^ __nullable)(void))prepearingCompletion
      printCompletion:(void(^ __nullable)(void))printCompletion;

- (void)cancel;

@end
