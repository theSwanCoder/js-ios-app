/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.3
 */

@import Foundation;

@interface JMDashboardParameter : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSArray <NSString *>*values;
- (instancetype)initWithData:(NSDictionary *)data;
+ (instancetype)parameterWithData:(NSDictionary *)data;
- (void)updateValuesWithString:(NSString *)stringValues;
- (NSString *)valuesAsString;
@end
