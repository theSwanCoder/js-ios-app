/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Olexandr Dahno odahno@tibco.com
 @since 2.2
 */

@import UIKit;

@interface JMEULAViewController : UIViewController
@property (nonatomic, copy) void(^ __nullable completion)(void);
@property (nonatomic) BOOL shouldUserAccept;
@end
