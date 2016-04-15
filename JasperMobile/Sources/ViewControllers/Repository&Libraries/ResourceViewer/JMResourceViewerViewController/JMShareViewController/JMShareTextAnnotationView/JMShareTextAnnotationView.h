//
//  JMShareTextAnnotationView.h
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/13/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMShareTextAnnotationView : UIControl

+ (instancetype)shareTextAnnotationWithText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font availableFrame:(CGRect)availableFrame;

@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) BOOL borders;

@end
