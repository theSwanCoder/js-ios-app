/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.5
 */
#import <UIKit/UIKit.h>

@interface JMShareImageActivityItemProvider : UIActivityItemProvider <UIActivityItemSource>

- (nonnull instancetype)initWithImage:(nonnull UIImage *)image;

@end
