/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

@import Foundation;

typedef NS_ENUM(NSInteger, JMJavascriptRequestErrorType) {
    JMJavascriptRequestErrorTypeWindow,
    JMJavascriptRequestErrorTypeSessionDidExpire,
    JMJavascriptRequestErrorTypeSessionDidRestore,
    JMJavascriptRequestErrorTypeUnexpected,
    JMJavascriptRequestErrorTypeCancel,
    JMJavascriptRequestErrorTypeOther,
};

typedef NS_ENUM(NSInteger, JMJavascriptNamespace) {
    JMJavascriptNamespaceDefault,
    JMJavascriptNamespaceVISReport,
    JMJavascriptNamespaceVISDashboard,
    JMJavascriptNamespaceRESTReport,
    JMJavascriptNamespaceRESTDashboard
};

@interface JMJavascriptRequest : NSObject <NSCopying>
- (instancetype __nullable)initWithCommand:(NSString * __nonnull)command
                               inNamespace:(JMJavascriptNamespace)namespace
                                parameters:(NSDictionary * __nullable)parameters;
+ (instancetype __nullable)requestWithCommand:(NSString * __nonnull)command
                                  inNamespace:(JMJavascriptNamespace)namespace
                                   parameters:(NSDictionary * __nullable)parameters;
- (NSString *__nonnull)fullJavascriptRequestString;
- (NSString *__nonnull)fullCommand;
@end
