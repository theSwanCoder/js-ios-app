/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMJavascriptRequestExecutor.h"

@interface JMJavascriptEvent : NSObject
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) id listener;
@property (nonatomic, copy, readonly) JMJavascriptRequestCompletion callback;
- (instancetype)initWithIdentifier:(NSString *)identifier listener:(id)listener callback:(JMJavascriptRequestCompletion)callback;
+ (instancetype)eventWithIdentifier:(NSString *)identifier listener:(id)listener callback:(JMJavascriptRequestCompletion)callback;
@end
