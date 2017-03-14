/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>

@interface JMUITestServerProfile : NSObject
@property(nonatomic, copy, readonly) NSString *alias;
@property(nonatomic, copy, readonly) NSString *url;
@property(nonatomic, copy, readonly) NSString *username;
@property(nonatomic, copy, readonly) NSString *password;
@property(nonatomic, copy, readonly) NSString *organization;
- (instancetype)initWithAlias:(NSString *)alias
                          URL:(NSString *)url
                     username:(NSString *)username
                     password:(NSString *)password
                 organization:(NSString *)organization;
@end
