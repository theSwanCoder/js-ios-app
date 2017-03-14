/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

@protocol JMReportLoaderProtocol;

@interface JMVisualizeReportLoader : NSObject <JMReportLoaderProtocol>
@property (nonatomic, weak) id<JMReportLoaderDelegate> delegate;
@end

