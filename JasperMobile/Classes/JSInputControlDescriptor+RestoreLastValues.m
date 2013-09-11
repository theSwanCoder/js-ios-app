/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JSInputControlDescriptor+RestoreLastValues.m
//  Jaspersoft Corporation
//

#import <Objection-iOS/JSObjection.h>
#import "JSInputControlDescriptor+RestoreLastValues.h"

@implementation JSInputControlDescriptor (RestoreLastValues)

- (void)restoreLastValues:(id)values
{
    if (!values) return;

    JSConstants *constants = [[JSObjection defaultInjector] getObject:[JSConstants class]];
    NSString *type = self.type;

    if ([type isEqualToString:constants.ICD_TYPE_SINGLE_SELECT] ||
        [type isEqualToString:constants.ICD_TYPE_SINGLE_SELECT_RADIO] ||
        [type isEqualToString:constants.ICD_TYPE_MULTI_SELECT] ||
        [type isEqualToString:constants.ICD_TYPE_MULTI_SELECT_CHECKBOX]) {

        BOOL isSingleSelect = [type isEqualToString:constants.ICD_TYPE_SINGLE_SELECT] || [type isEqualToString:constants.ICD_TYPE_SINGLE_SELECT_RADIO];

        for (JSInputControlOption *option in self.state.options) {
            if ((isSingleSelect && [values isEqualToString:option.value]) ||
                (!isSingleSelect && [values containsObject:option.value])) {
                option.selected = [JSConstants stringFromBOOL:YES];
            } else {
                option.selected = [JSConstants stringFromBOOL:NO];
            }
        }
    } else {
        self.state.value = values;
    }
}

@end
