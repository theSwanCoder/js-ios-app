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
//  JMLocalization.m
//  TIBCO JasperMobile
//

#import "JMLocalization.h"

NSString * const JMPreferredLanguage = @"en";
NSString * const JMLocalizationBundleType = @"lproj";

@implementation JMLocalization

+ (NSString *)localizedStringForKey:(NSString *)key
{
    NSURL *localizationBundleURL = [[NSBundle bundleForClass:[self class]] bundleURL];
    NSBundle *localizationBundle = localizationBundleURL ? [NSBundle bundleWithURL:localizationBundleURL] : [NSBundle mainBundle];
    
    NSString *localizedString = NSLocalizedStringFromTableInBundle(key, nil, localizationBundle, comment);
    
    if (![[NSLocale preferredLanguages][0] isEqualToString:JMPreferredLanguage] && [localizedString isEqualToString:key]) {
        NSString *path = [localizationBundle pathForResource:JMPreferredLanguage ofType:JMLocalizationBundleType];
        NSBundle *preferredLanguageBundle = [NSBundle bundleWithPath:path];
        localizedString = [preferredLanguageBundle localizedStringForKey:key value:@"" table:nil];
    }
    
    return localizedString;
}

@end

NSString *JMLocalizedString(NSString *key)
{
    return [JMLocalization localizedStringForKey:key];
}
