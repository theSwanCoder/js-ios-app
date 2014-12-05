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
//  UIAlertView+Additions.m
//  TIBCO JasperMobile
//

#import "UIAlertView+Additions.h"

@interface UIAlertView () <UIAlertViewDelegate>
@end

static NSMutableArray *_showedAlertsCompetionBlocks;

@implementation UIAlertView (LocalizedAlert)

+ (void)initialize{
    if (self == [UIAlertView class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _showedAlertsCompetionBlocks = [NSMutableArray array];
        });
    }
}

+ (UIAlertView *)localizedAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
              cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *view = [self localizedAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    view.delegate = delegate;
    return view;
}

+ (UIAlertView *)localizedAlertWithTitle:(NSString *)title message:(NSString *)message completion:(clickedButtonAtIndexCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *view = [self localizedAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    view.delegate = view;
    [_showedAlertsCompetionBlocks addObject:[completion copy]];
    view.tag = [_showedAlertsCompetionBlocks count];
    return view;
}

+ (UIAlertView *)localizedAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(title, nil)
                                                   message:JMCustomLocalizedString(message, nil)
                                                  delegate:nil
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([_showedAlertsCompetionBlocks count] > alertView.tag - 1) {
        clickedButtonAtIndexCompletion completionBlock = [_showedAlertsCompetionBlocks objectAtIndex:alertView.tag - 1];
        if (completionBlock) {
            completionBlock(self, buttonIndex);
            [_showedAlertsCompetionBlocks removeObject:completionBlock];
        }
    }
}
@end
