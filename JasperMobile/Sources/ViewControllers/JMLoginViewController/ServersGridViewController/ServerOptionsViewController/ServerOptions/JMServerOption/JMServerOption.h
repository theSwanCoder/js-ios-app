/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;

@interface JMServerOption : NSObject

@property (nonatomic, strong, readonly) NSString *titleString;
@property (nonatomic, strong) NSString *errorString;
@property (nonatomic, strong) id        optionValue;
@property (nonatomic, strong, readonly) NSString *cellIdentifier;
@property (nonatomic, assign, readonly) BOOL      editable;       // By default YES
- (instancetype)initWithTitle:(NSString *)title
                  optionValue:(id)optionValue
               cellIdentifier:(NSString *)cellIdentifier
                     editable:(BOOL)editable;
+ (instancetype)optionWithTitle:(NSString *)title
                    optionValue:(id)optionValue
                 cellIdentifier:(NSString *)cellIdentifier
                       editable:(BOOL)editable;
@end
