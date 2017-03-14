/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import UIKit;
@class JMResource;

@interface JMResourceViewerInfoPageManager : NSObject
@property (nonatomic, weak) UIViewController * __nullable controller;
- (void)showInfoPageForResource:(JMResource *__nonnull)resource;
@end
