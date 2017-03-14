/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

@import UIKit;

@interface JMIntroModel : NSObject
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *pageDescription;
@property (nonatomic, strong) UIImage *pageImage;

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image;

@end
