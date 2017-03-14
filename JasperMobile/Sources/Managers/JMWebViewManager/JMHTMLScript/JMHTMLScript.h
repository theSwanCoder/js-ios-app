/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JMHTMLScriptType) {
    JMHTMLScriptTypeLink,
    JMHTMLScriptTypeSource,
    JMHTMLScriptTypeRenderHighchart,
    JMHTMLScriptTypeOther
};

@interface JMHTMLScript : NSObject
@property (nonatomic, assign) JMHTMLScriptType type;
@property (nonatomic, strong) id value;
@end
