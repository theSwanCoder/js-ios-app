/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JSLocalization.h
//  Jaspersoft Corporation
//

#import "JSLocalization.h"

static NSString * const preferredLanguage = @"en";

@implementation JSLocalization

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSString *localizedString = NSLocalizedString(key, nil);
    if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:preferredLanguage] &&
        [localizedString isEqualToString:key]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:preferredLanguage ofType:@"lproj"];
        NSBundle *preferredLanguageBundle = [NSBundle bundleWithPath:path];
        localizedString = [preferredLanguageBundle localizedStringForKey:key value:@"" table:nil];
    }
    
    return localizedString;
}

@end
