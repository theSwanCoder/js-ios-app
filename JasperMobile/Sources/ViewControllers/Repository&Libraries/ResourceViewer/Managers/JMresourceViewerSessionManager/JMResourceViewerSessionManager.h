/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import UIKit;

@class JMReportViewerVC;

@interface JMResourceViewerSessionManager : NSObject
@property (nonatomic, weak, nullable) UIViewController *controller;
@property (nonatomic, copy, nullable) void(^cleanAction)(void);
@property (nonatomic, copy, nullable) void(^executeAction)(void);
@property (nonatomic, copy, nullable) void(^exitAction)(void);
- (void)handleSessionDidExpire;
- (void)handleSessionDidRestore;
@end
