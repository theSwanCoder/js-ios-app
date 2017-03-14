/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.1
 */

#import <UIKit/UIKit.h>
#import "JMResourceViewerConfigurator.h"

@protocol JMReportLoaderProtocol;

@interface JMReportViewerConfigurator : JMResourceViewerConfigurator
@property (nonatomic, strong, readonly) id <JMReportLoaderProtocol> __nonnull reportLoader;

@end
