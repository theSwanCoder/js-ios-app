/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.5
 */


#import <UIKit/UIKit.h>

@interface JMShareTextAnnotationView : UIControl

+ (instancetype)shareTextAnnotationWithText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font availableFrame:(CGRect)availableFrame;

@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) BOOL borders;

@end
