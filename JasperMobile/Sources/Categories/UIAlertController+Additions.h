/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.2
 */

#import <UIKit/UIKit.h>

typedef void(^UIAlertControllerCompletionBlock)(UIAlertController * __nonnull controller, UIAlertAction * __nonnull action);

@interface UIAlertController (Additions)

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message;

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nonnull NSString *)cancelButtonTitle cancelCompletionHandler:(__nullable UIAlertControllerCompletionBlock)handler;

+ (nonnull instancetype)alertTextDialogueControllerWithLocalizedTitle:(nullable NSString *)title
                                                              message:(nullable NSString *)message
                                        textFieldConfigurationHandler:(void (^ __nullable)(UITextField * __nonnull textField))configurationHandler // Not set delegate for textField here!
                                                textValidationHandler:(NSString * __nonnull (^ __nullable)(NSString * __nullable text))validationHandler
                                            textEditCompletionHandler:(void (^ __nullable)(NSString * __nullable text))editCompletionHandler;

- (void)addActionWithLocalizedTitle:(nonnull NSString *)title style:(UIAlertActionStyle)style handler:(__nullable UIAlertControllerCompletionBlock)handler;

@end
