/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "UIAlertController+Additions.h"
#import "JMLocalization.h"

@interface UIAlertController (UITextFieldDelegate) <UITextFieldDelegate>

@end

@implementation UIAlertController (UITextFieldDelegate)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
@end


@implementation UIAlertController (Additions)

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:JMLocalizedString(title)
                                                                             message:JMLocalizedString(message)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    return alertController;
}

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nonnull NSString *)cancelButtonTitle cancelCompletionHandler:(__nullable UIAlertControllerCompletionBlock)handler
{
    UIAlertController *alertController = [self alertControllerWithLocalizedTitle:title message:message];
    [alertController addActionWithLocalizedTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:handler];
    return alertController;
}

+ (nonnull instancetype)alertTextDialogueControllerWithLocalizedTitle:(nullable NSString *)title
                                                              message:(nullable NSString *)message
                                        textFieldConfigurationHandler:(void (^ __nullable)(UITextField * __nonnull textField))configurationHandler
                                                textValidationHandler:(NSString * __nonnull (^ __nullable)(NSString * __nullable text))validationHandler
                                            textEditCompletionHandler:(void (^ __nullable)(NSString * __nullable text))editCompletionHandler
{
    UIAlertController *alertController = [self alertControllerWithLocalizedTitle:title message:message];
    __block id textFieldObserver;
    
    [alertController addActionWithLocalizedTitle:@"dialog_button_ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        if (editCompletionHandler) {
            NSString *text = [controller.textFields objectAtIndex:0].text;
            editCompletionHandler(text);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:textFieldObserver name:UITextFieldTextDidChangeNotification object:controller.textFields[0]];
    }];
    
    [alertController addActionWithLocalizedTitle:@"dialog_button_cancel" style:UIAlertActionStyleCancel handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:textFieldObserver name:UITextFieldTextDidChangeNotification object:controller.textFields[0]];
    }];
    
    __weak typeof(alertController) weakAlertController = alertController;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        __strong typeof (weakAlertController) strongAlertController = weakAlertController;
        if (strongAlertController) {
            
            if (validationHandler) {
                textFieldObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                    NSString *errorMessage = validationHandler(textField.text);
                    strongAlertController.message = errorMessage;
                    [[strongAlertController.actions objectAtIndex:0] setEnabled:!errorMessage];
                }];
            }
            if (configurationHandler) {
                configurationHandler(textField);
                [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
            }
        }
    }];
    
    return alertController;
}

- (void)addActionWithLocalizedTitle:(nonnull NSString *)title style:(UIAlertActionStyle)style handler:(UIAlertControllerCompletionBlock _Nullable)handler
{
    __weak typeof(self) weakSelf = self;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:JMLocalizedString(title) style:style handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                handler(strongSelf, action);
            } else {
                @throw [NSException exceptionWithName:@"UIAlertController is nil" reason:@"It's impossible, but somthing went wrong!" userInfo:nil];
            }
        }
    }];
    [self addAction:alertAction];
}

@end
