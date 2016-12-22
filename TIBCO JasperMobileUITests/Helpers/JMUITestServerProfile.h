//
//  JMUITestProfile.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 11/3/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

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
