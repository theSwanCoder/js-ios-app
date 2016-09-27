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

#pragma mark - Public API
+ (NSString *)accessibilityLanguage
{
    NSArray *supportedLocalizations = [[NSBundle mainBundle] localizations];
    for (NSString *currentLanguage in [self listOfPreferredLanguages]) {
        if ([supportedLocalizations containsObject:currentLanguage]) {
            return currentLanguage;
        }
    }
    return JMPreferredLanguage;
}

+ (void)localizeStringForKey:(NSString *)key completion:(void (^)(NSString *localizedString, NSString *languageString))completion
{
    if (![key length]) {
        completion(nil, nil);
        return;
    }
    NSBundle *localizationBundle = [NSBundle bundleForClass:[self class]];
    NSString *localizedString = [self localizeStringForKey:key language:JMPreferredLanguage inBundle:localizationBundle];
    for (NSString *currentLanguage in [self listOfPreferredLanguages]) {
        if (![currentLanguage isEqualToString:JMPreferredLanguage]) {
            NSString *currentLocalizedString = [self localizeStringForKey:key language:currentLanguage inBundle:localizationBundle];
            if (![currentLocalizedString isEqualToString:key]) {
                if (![currentLocalizedString isEqualToString:localizedString]) {
                    completion(currentLocalizedString, currentLanguage);
                    return;
                } else { //Check all other localisations
                    NSMutableArray *supportedLocalizations = [[[NSBundle mainBundle] localizations] mutableCopy];
                    [supportedLocalizations removeObject:JMPreferredLanguage];
                    [supportedLocalizations removeObject:currentLanguage];
                    
                    for (NSString *language in supportedLocalizations) {
                        NSString *currentString = [self localizeStringForKey:key language:language inBundle:localizationBundle];
                        if (![currentString isEqualToString:localizedString]) {
                            completion(currentLocalizedString, currentLanguage);
                            return;
                        }
                    }
                }
            }
        } else {
            break;
        }
    }
    completion(localizedString, JMPreferredLanguage);
}

#pragma mark - Utilites
+ (NSString *)localizeStringForKey:(NSString *)key language:(NSString *)language inBundle:(NSBundle *)bundle
{
    NSString *path = [bundle pathForResource:language ofType:JMLocalizationBundleType];
    NSBundle *preferredLanguageBundle = [NSBundle bundleWithPath:path];
    return [preferredLanguageBundle localizedStringForKey:key value:@"" table:nil];
}

+ (NSArray *)listOfPreferredLanguages
{
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSMutableArray *clearedLanguages = [NSMutableArray array];
    for (NSInteger i = 0; i < preferredLanguages.count; i++) {
        NSString *currentLanguage = [preferredLanguages objectAtIndex:i];
        NSInteger dividerPosition = [currentLanguage rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_-"]].location;
        if (dividerPosition != NSNotFound) {
            currentLanguage = [currentLanguage substringToIndex:dividerPosition];
        }
        [clearedLanguages addObject:currentLanguage];
    }
    return clearedLanguages;
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
