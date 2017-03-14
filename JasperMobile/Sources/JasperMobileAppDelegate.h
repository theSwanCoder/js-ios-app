/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @author Oleksandr Dahno odahno@tibco.com
 @since 1.6
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


extern NSString *const JMAppDelegateWillDestroyExternalWindowNotification;

@interface JasperMobileAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *externalWindow;
- (BOOL)isExternalScreenAvailable;
@end
