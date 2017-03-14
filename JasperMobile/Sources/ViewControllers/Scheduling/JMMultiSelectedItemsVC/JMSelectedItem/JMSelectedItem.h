/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

@import UIKit;

@interface JMSelectedItem : NSObject
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, strong, readonly) id value;
- (instancetype)initWithTitle:(NSString *)title value:(id)value selected:(BOOL)selected;
+ (instancetype)itemWithTitle:(NSString *)title value:(id)value selected:(BOOL)selected;
@end
