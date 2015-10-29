/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  UIAlertController+Additions.m
//  TIBCO JasperMobile
//

#import "UIAlertController+Additions.h"

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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:JMCustomLocalizedString(title, nil)
                                                                             message:JMCustomLocalizedString(message, nil)
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
    
    [alertController addActionWithLocalizedTitle:@"dialog.button.ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        if (editCompletionHandler) {
            NSString *text = [controller.textFields objectAtIndex:0].text;
            editCompletionHandler(text);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:textFieldObserver name:UITextFieldTextDidChangeNotification object:controller.textFields[0]];
    }];
    
    [alertController addActionWithLocalizedTitle:@"dialog.button.cancel" style:UIAlertActionStyleCancel handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
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
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:JMCustomLocalizedString(title, nil) style:style handler:^(UIAlertAction * _Nonnull action) {
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
