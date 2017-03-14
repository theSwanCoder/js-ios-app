/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.5
*/

#import <Foundation/Foundation.h>

@class JMHTMLScript;

@interface JMHTMLParser : NSObject
@property (nonatomic, strong) NSArray <JMHTMLScript *> *__nullable scripts;

- (instancetype __nullable)initWithHTMLString:(NSString * __nonnull)htmlString;
+ (instancetype __nullable)parserWithHTMLString:(NSString * __nonnull)htmlString;
- (void)parse;
- (NSString * __nullable)content;
@end
