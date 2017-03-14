/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
