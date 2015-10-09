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

@implementation UIAlertController (Additions)

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:JMCustomLocalizedString(title, nil)
                                                                             message:JMCustomLocalizedString(message, nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    return alertController;
}

+ (nonnull instancetype)alertControllerWithLocalizedTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nonnull NSString *)cancelButtonTitle cancelCompletionHandler:(void (^ __nullable)(UIAlertAction * __nonnull action))handler
{
    UIAlertController *alertController = [self alertControllerWithLocalizedTitle:title message:message];
    [alertController addActionWithLocalizedTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:handler];
    return alertController;
}

- (void)addActionWithLocalizedTitle:(nonnull NSString *)title style:(UIAlertActionStyle)style handler:(void (^ __nullable)(UIAlertAction * __nonnull action))handler
{
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:JMCustomLocalizedString(title, nil) style:style handler:handler];
    [self addAction:alertAction];
}

@end
