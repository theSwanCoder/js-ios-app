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
//  UIAlertView+LocalizedAlert.m
//  TIBCO JasperMobile
//

#import "UIAlertView+LocalizedAlert.h"

@implementation UIAlertView (LocalizedAlert)

+ (UIAlertView *)localizedAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
              cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(title, nil)
                                                   message:JMCustomLocalizedString(message, nil) 
                                                  delegate:delegate 
                                         cancelButtonTitle:JMCustomLocalizedString(cancelButtonTitle, nil) 
                                         otherButtonTitles:nil];
    va_list args;
    va_start (args, otherButtonTitles);
        while (otherButtonTitles != nil) {
            [view addButtonWithTitle:JMCustomLocalizedString(otherButtonTitles, nil)];
            otherButtonTitles = va_arg(args, NSString*);
        }
    va_end (args);

    return view;
}

@end
