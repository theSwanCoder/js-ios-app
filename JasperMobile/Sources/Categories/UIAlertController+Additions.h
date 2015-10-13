/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  UIAlertController+Additions.h
//  TIBCO JasperMobile
//

#import <UIKit/UIKit.h>

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.2
 */

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
