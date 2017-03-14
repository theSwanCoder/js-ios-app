/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import <Foundation/Foundation.h>

@interface JMLocalization : NSObject

+ (NSString *)localizedStringForKey:(NSString *)key;

@end

NSString *JMLocalizedString(NSString *key);
