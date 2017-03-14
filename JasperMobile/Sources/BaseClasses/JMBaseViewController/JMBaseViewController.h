/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.1.1
 */

#import "GAITrackedViewController.h"


@interface JMBaseViewController : GAITrackedViewController
- (UIBarButtonItem *)backButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle;
// Could be overridden subclasses to add analytics
- (NSString *)additionalsToScreenName;
@end
