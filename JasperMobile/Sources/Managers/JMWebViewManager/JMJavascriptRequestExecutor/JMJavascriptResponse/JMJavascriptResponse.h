/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

@import Foundation;

typedef NS_ENUM(NSInteger, JMJavascriptResponseType) {
    JMJavascriptCallbackTypeLog,
    JMJavascriptCallbackTypeListener,
    JMJavascriptCallbackTypeCallback
};

@interface JMJavascriptResponse : NSObject
@property (nonatomic, assign) JMJavascriptResponseType type;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSDictionary *parameters;
@end
