/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import UIKit;

@interface JMResourceViewerDocumentManager : NSObject
@property (nonatomic, weak) UIViewController * __nullable controller;
- (void)showOpenInMenuForResourceWithURL:(NSURL * __nonnull)URL;
@end
