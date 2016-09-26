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

+ (void)localizeStringForKey:(NSString *)key completion:(void (^)(NSString *localizedString, NSString *languageString))completion
{
    NSURL *localizationBundleURL = [[NSBundle bundleForClass:[self class]] bundleURL];
    NSBundle *localizationBundle = localizationBundleURL ? [NSBundle bundleWithURL:localizationBundleURL] : [NSBundle mainBundle];
    
    NSString *localizedString = NSLocalizedStringFromTableInBundle(key, nil, localizationBundle, comment);
    
    if (![[NSLocale preferredLanguages][0] isEqualToString:JMPreferredLanguage] && [localizedString isEqualToString:key]) {
        NSString *path = [localizationBundle pathForResource:JMPreferredLanguage ofType:JMLocalizationBundleType];
        NSBundle *preferredLanguageBundle = [NSBundle bundleWithPath:path];
        localizedString = [preferredLanguageBundle localizedStringForKey:key value:@"" table:nil];
    }
    if (completion) {
        
#warning HERE SHOULD BE LANGUAGE FOR CURRENT STRING!
        completion(localizedString, [self accessibilityLanguage]);
    }
}

+ (NSString *)accessibilityLanguage
{
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSArray *supportedLocalizations = [[NSBundle mainBundle] localizations];
    for (NSInteger i = 0; i < preferredLanguages.count; i++) {
        NSString *currentLanguage = [preferredLanguages objectAtIndex:i];
        NSInteger dividerPosition = [currentLanguage rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_-"]].location;
        if (dividerPosition != NSNotFound) {
            currentLanguage = [currentLanguage substringToIndex:dividerPosition];
        }
        if ([supportedLocalizations containsObject:currentLanguage]) {
            return currentLanguage;
        }
    }
    
    return JMPreferredLanguage;
}

+ (void)setAccessibilityForElement:(NSObject *)accessibilityElement withTextKey:(NSString *)key accessibility:(BOOL)accessibility
{
    [JMLocalization localizeStringForKey:key completion:^(NSString *localizedString, NSString *languageString) {
        accessibilityElement.isAccessibilityElement = accessibility;
        accessibilityElement.accessibilityLabel = localizedString;
        accessibilityElement.accessibilityLanguage = languageString;
    }];
}

@end

NSString *JMLocalizedString(NSString *key)
{
    __block NSString *resultLocalizedString;
    [JMLocalization localizeStringForKey:key completion:^(NSString *localizedString, NSString *languageString) {
        resultLocalizedString = localizedString;
    }];
    return resultLocalizedString;
}
