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
#import "JMLocalization.h"
#import "NSObject+Additions.h"

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
    
    [alertController setAccessibility:YES withTextKey:title identifier:JMAlertControllerAccessibilityId];
    return alertController;
}

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonType:(JMAlertControllerActionType)cancelButtonType cancelCompletionHandler:(UIAlertControllerCompletionBlock _Nullable)handler
{
    UIAlertController *alertController = [self alertControllerWithLocalizedTitle:title message:message];
    [alertController addActionWithType:cancelButtonType style:UIAlertActionStyleCancel handler:handler];
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
    
    [alertController addActionWithType:JMAlertControllerActionType_Ok style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        if (editCompletionHandler) {
            NSString *text = [controller.textFields objectAtIndex:0].text;
            editCompletionHandler(text);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:textFieldObserver name:UITextFieldTextDidChangeNotification object:controller.textFields[0]];
    }];
    
    [alertController addActionWithType:JMAlertControllerActionType_Cancel style:UIAlertActionStyleCancel handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:textFieldObserver name:UITextFieldTextDidChangeNotification object:controller.textFields[0]];
    }];
    
    __weak typeof(alertController) weakAlertController = alertController;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        __strong typeof (weakAlertController) strongAlertController = weakAlertController;
        if (strongAlertController) {
            textField.isAccessibilityElement = YES;
            textField.accessibilityIdentifier = JMAlertControllerTextFieldAccessibilityId;
            
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

- (void)addActionWithType:(JMAlertControllerActionType)actionType style:(UIAlertActionStyle)style handler:(UIAlertControllerCompletionBlock)handler
{
    [self addActionWithLocalizedTitle:[self actionButtonTitleWithType:actionType]
                      accessibilityId:[self accesssibilityIdWithActionType:actionType]
                                style:style
                              handler:handler];
}

- (void)addActionWithLocalizedTitle:(NSString *)title accessibilityId:(NSString *)accessibilityId style:(UIAlertActionStyle)style handler:(UIAlertControllerCompletionBlock)handler
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
    [alertAction setAccessibility:YES withTextKey:title identifier:accessibilityId];
    [self addAction:alertAction];
}

- (NSString *)actionButtonTitleWithType:(JMAlertControllerActionType)actionType
{
    switch (actionType) {
        case JMAlertControllerActionType_Done:
            return @"dialog_button_done";
        case JMAlertControllerActionType_Accept:
            return @"dialog_title_accept";
        case JMAlertControllerActionType_Cancel:
            return @"dialog_button_cancel";
        case JMAlertControllerActionType_Delete:
            return @"dialog_button_delete";
        case JMAlertControllerActionType_Ok:
            return @"dialog_button_ok";
        case JMAlertControllerActionType_Save:
            return @"dialog_button_save";
        case JMAlertControllerActionType_Reload:
            return @"dialog_button_reload";
        case JMAlertControllerActionType_Retry:
            return @"dialog_button_retry";
        case JMAlertControllerActionType_Continue:
            return @"dialog_button_continue";
        case JMAlertControllerActionType_Apply:
            return @"dialog_button_apply";
        default:
            NSCAssert(NO, @"wrong type: %zd", actionType);
    }
}

- (NSString *)accesssibilityIdWithActionType:(JMAlertControllerActionType)actionType
{
    switch (actionType) {
        case JMAlertControllerActionType_Done:
            return JMButtonDoneAccessibilityId;
        case JMAlertControllerActionType_Accept:
            return JMButtonAcceptAccessibilityId;
        case JMAlertControllerActionType_Cancel:
            return JMButtonCancelAccessibilityId;
        case JMAlertControllerActionType_Delete:
            return JMButtonDeleteAccessibilityId;
        case JMAlertControllerActionType_Ok:
            return JMButtonOkAccessibilityId;
        case JMAlertControllerActionType_Save:
            return JMButtonSaveAccessibilityId;
        case JMAlertControllerActionType_Reload:
            return JMButtonReloadAccessibilityId;
        case JMAlertControllerActionType_Retry:
            return JMButtonRetryAccessibilityId;
        case JMAlertControllerActionType_Continue:
            return JMButtonContinueAccessibilityId;
        case JMAlertControllerActionType_Apply:
            return JMButtonApplyAccessibilityId;
        default:
            NSCAssert(NO, @"wrong type: %zd", actionType);
    }

}

@end
