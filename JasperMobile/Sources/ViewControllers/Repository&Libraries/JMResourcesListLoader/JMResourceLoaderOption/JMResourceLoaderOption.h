/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

#import <Foundation/Foundation.h>

@interface JMResourceLoaderOption : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) id value;
- (instancetype)initWithTitle:(NSString *)title value:(id)value;
+ (instancetype)optionWithTitle:(NSString *)title value:(id)value;
@end
