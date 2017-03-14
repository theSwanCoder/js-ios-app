/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.0
 */

#import "JSReportLoader.h"
#import "JMReportLoaderProtocol.h"

@interface JMRestReportLoader : JSReportLoader <JMReportLoaderProtocol>
@property (nonatomic, weak) id<JMReportLoaderDelegate> delegate;
@end
