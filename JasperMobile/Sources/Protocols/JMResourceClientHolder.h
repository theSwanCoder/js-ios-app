/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import <Foundation/Foundation.h>


/**
 This protocol aggregates all the information implementing object should know about
 to work with JasperServer Repository Service
 */

@class JMResource;

@protocol JMResourceClientHolder <NSObject>
@property (nonatomic, strong) JMResource *resource;
@end
