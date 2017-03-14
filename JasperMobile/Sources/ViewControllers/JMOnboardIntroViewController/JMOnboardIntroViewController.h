/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

@import UIKit;

typedef NS_ENUM(NSInteger, JMOnboardIntroPage) {
    JMOnboardIntroPageWelcome,
    JMOnboardIntroPageStayConnected,
    JMOnboardIntroPageInstanceAccess,
    JMOnboardIntroPageSeemlessIntegration
};

@interface JMOnboardIntroViewController : UIViewController
@end
