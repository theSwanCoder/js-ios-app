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
//  JMThemesManager.m
//  TIBCO JasperMobile
//


#import "JMThemesManager.h"
#import "JasperMobileAppDelegate.h"

#import "UIColor+RGBComponent.h"

NSString * const kJMThemePlatformIPhoneKey = @"iPhone";
NSString * const kJMThemePlatformIPadKey = @"iPad";

NSString * const kJMThemeAttributeTypeKey = @"AttributeType";
NSString * const kJMThemeAttributeTypeColor = @"Color";
NSString * const kJMThemeAttributeTypeFont = @"Font";

NSString * const kJMThemeAttributeValueKey = @"AttributeValue";
NSString * const kJMThemeAttributeValueFontFamily = @"FontFamily";
NSString * const kJMThemeAttributeValueFontSize = @"FontSize";
NSString * const kJMThemeAttributeValueFontBold = @"Bold";
NSString * const kJMThemeAttributeValueFontItalic = @"Italic";



// Login View
NSString * const kJMThemeLoginViewBackgroundColor = @"LoginView.background_color";
NSString * const kJMThemeLoginViewPlaceholderBackgroundColor = @"LoginView.placeholder_background_color";
NSString * const kJMThemeLoginViewTextFieldsBackgroundColor = @"LoginView.textfields_background_color";
NSString * const kJMThemeLoginViewTextFieldsTextColor = @"LoginView.textfields_text_color";
NSString * const kJMThemeLoginLoginButtonBackgroundColor = @"LoginView.login_button_background_color";
NSString * const kJMThemeLoginLoginButtonTextColor = @"LoginView.login_button_text_color";
NSString * const kJMThemeLoginTryDemoButtonBackgroundColor = @"LoginView.trydemo_button_background_color";
NSString * const kJMThemeLoginTryDemoButtonTextColor = @"LoginView.trydemo_button_text_color";

// Menu View
NSString * const kJMThemeMenuViewBackgroundColor = @"MenuView.background_color";
NSString * const kJMThemeMenuViewTextColor = @"MenuView.text_color";
NSString * const kJMThemeMenuViewSelectedTextColor = @"MenuView.selected_text_color";
NSString * const kJMThemeMenuViewSeparatorColor = @"MenuView.separator_color";

//Server Profiles
NSString * const kJMThemeServerProfilesBackgroundColor = @"ServerProfiles.background_color";
NSString * const kJMThemeServerProfilePreviewBackgroundColor = @"ServerProfiles.profile_preview_background_color";
NSString * const kJMThemeServerProfileTitleTextColor = @"ServerProfiles.profile_title_text_color";
NSString * const kJMThemeServerProfileDetailsTextColor = @"ServerProfiles.profile_details_text_color";
NSString * const kJMThemeServerProfileSaveButtonBackgroundColor = @"ServerProfiles.save_button_background_color";
NSString * const kJMThemeServerProfileSaveButtonTextColor = @"ServerProfiles.save_button_text_color";

// Common
NSString * const kJMThemeViewBackgroundColor = @"Common.views_background_color";
NSString * const kJMThemeBarsBackgroundColor = @"Common.bars_background_color";
NSString * const kJMThemeBarItemsTextColor = @"Common.bar_items_text_color";
NSString * const kJMThemePopupsBackgroundColor = @"Common.popups_background_color";
NSString * const kJMThemeTableViewCellTitleColor = @"Common.table_view_cell_title_text_color";
NSString * const kJMThemeTableViewCellErrorColor = @"Common.table_view_cell_error_text_color";

NSString * const kJMThemeTextFieldBackgroundColor = @"Common.textfield_background_color";
NSString * const kJMThemeTextFieldEditableTextColor = @"Common.textfield_editable_text_color";
NSString * const kJMThemeTextFieldUnEditableTextColor = @"Common.textfield_uneditable_text_color";





NSString * const kJMThemeAttributeCollectionViewBackgroundColor = @"collectionview_background_color";



@interface JMThemesManager ()

@property (nonatomic, strong) NSDictionary *themesDictionary;
@property (nonatomic, strong) NSDictionary *defaultThemesDictionary;

@end

@implementation JMThemesManager
+ (instancetype)sharedManager
{
    static JMThemesManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [JMThemesManager new];
        [sharedManager prepareDefaultThemeSettings];
    });
    
    return sharedManager;
}

- (void) applyCurrentTheme
{
    self.themesDictionary = [NSDictionary dictionaryWithContentsOfFile:[self currentThemePath]];
    
    // Update UIAppearence
    [[UINavigationBar appearance] setBarTintColor: [self barsBackgroundColor]];
    [[UIToolbar appearance] setBarTintColor: [self barsBackgroundColor]];

    
    
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[self barItemsTextColor]}];
    [[UINavigationBar appearance] setTintColor:[self barItemsTextColor]];
    [[UIToolbar appearance] setTintColor: [self barItemsTextColor]];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[self barItemsTextColor], NSForegroundColorAttributeName, [JMThemesManager navigationBarTitleFont], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    
    if ([UIDevice currentDevice].systemVersion.integerValue < 8) {
        // Here is hack for using UIPrintInteractionController
        NSDictionary *textTitleOptionsForPopover = [NSDictionary dictionaryWithObjectsAndKeys:[self barsBackgroundColor], NSForegroundColorAttributeName, [JMThemesManager navigationBarTitleFont], NSFontAttributeName, nil];
        [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:textTitleOptionsForPopover];
    }
    
    NSDictionary *barButtonTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[self barItemsTextColor], NSForegroundColorAttributeName, [JMThemesManager navigationItemsFont], NSFontAttributeName, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateNormal];

    
    
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
    }
}

- (BOOL)applyThemeWithURL:(NSURL *)themeURL error:(NSError **)error
{
    if (!themeURL) {
#warning HERE NEED CHECK ERROR INIALISATION
        if (error != NULL) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil];
        return NO;
    }
    
    NSDictionary *themeDictionary = [NSDictionary dictionaryWithContentsOfURL:themeURL];
    if (!themeDictionary && [themeDictionary count] == 0) {
        if (error != NULL) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil];
        return NO;
    }
    
    NSURL *newThemeURL = [NSURL fileURLWithPath:[self currentThemePath]];
    if (![[NSFileManager defaultManager] copyItemAtURL:themeURL toURL:newThemeURL error:error] && error) {
        return NO;
    }
    
    [self applyCurrentTheme];
    return YES;
}

#pragma mark - Private API
- (void) prepareDefaultThemeSettings
{
    NSString *defaultThemePath = [[NSBundle mainBundle] pathForResource:kJMDefaultThemeFileName ofType:kJMThemesFileFormat];
    self.defaultThemesDictionary = [NSDictionary dictionaryWithContentsOfFile:defaultThemePath];
}

- (NSString *)currentThemePath
{
    NSString *currentThemePath = [[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:kJMCurrentThemeFileName] stringByAppendingPathExtension:kJMThemesFileFormat];
    return currentThemePath;
}

- (id) attributeValueFromDictionary:(NSDictionary *)themeDictionary forKeyPath:(NSString *)keyPath
{
    if (themeDictionary) {
        // Fix for implementing color from image pattern
        if (themeDictionary == self.defaultThemesDictionary && ([keyPath isEqualToString:kJMThemeLoginViewBackgroundColor] ||
            [keyPath isEqualToString:kJMThemeServerProfilesBackgroundColor])) {
            return [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];
        }
        
        
        NSDictionary *attributeDictionary = [themeDictionary valueForKeyPath:keyPath];
        
        if (attributeDictionary && [attributeDictionary count] >= 2) {
            id attributeType  = [attributeDictionary objectForKey:kJMThemeAttributeTypeKey];
            id attributeValue = [attributeDictionary objectForKey:kJMThemeAttributeValueKey];
            if (attributeType && attributeValue && [attributeType isKindOfClass:[NSString class]]) {
                if ([attributeType isEqualToString:kJMThemeAttributeTypeColor]) {
                    if ([attributeValue isKindOfClass:[NSString class]]) {
                        return [UIColor colorFromHexString:[NSString stringWithFormat:@"#%@", attributeValue]];
                    }
                } else if ([attributeType isEqualToString:kJMThemeAttributeTypeFont]) {
                    if ([attributeValue isKindOfClass:[NSDictionary class]]) {
                        NSString *fontFamily = [attributeValue objectForKey:kJMThemeAttributeValueFontFamily];
                        NSNumber *fontSize = [attributeValue objectForKey:kJMThemeAttributeValueFontSize];
                        BOOL fontBold = [[attributeValue objectForKey:kJMThemeAttributeValueFontBold] boolValue];
                        BOOL fontItalic = [[attributeValue objectForKey:kJMThemeAttributeValueFontItalic] boolValue];
                        
                        if (fontFamily && fontSize) {
                            UIFont *font = [self fontWithFamily:fontFamily bold:fontBold italic:fontItalic size:[fontSize integerValue]];
                            if (font) {
                                return font;
                            }
                        }
                    }
                }
            }
        }
    }

    if (themeDictionary != self.defaultThemesDictionary) {
        return [self attributeValueFromDictionary:self.defaultThemesDictionary forKeyPath:keyPath];
    } else return nil;
}

- (UIFont*)fontWithFamily:(NSString*)family bold:(BOOL)bold italic:(BOOL)italic size:(CGFloat)pointSize {
    UIFontDescriptorSymbolicTraits traits = 0;
    if (bold)   traits |= UIFontDescriptorTraitBold;
    if (italic) traits |= UIFontDescriptorTraitItalic;
    UIFontDescriptor* fd = [UIFontDescriptor
                            fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute: family,
                                                               UIFontDescriptorTraitsAttribute: @{UIFontSymbolicTrait:
                                                                                                      [NSNumber numberWithInteger:traits]}}];
    NSArray* matches = [fd matchingFontDescriptorsWithMandatoryKeys:
                        [NSSet setWithObjects:UIFontDescriptorFamilyAttribute, UIFontDescriptorTraitsAttribute, nil]];
    if (matches.count == 0) return nil;
    return [UIFont fontWithDescriptor:matches[0] size:pointSize];
}

@end

@implementation JMThemesManager (UIFont)

+ (UIFont *)navigationBarTitleFont
{
    return [JMUtils isIphone] ? [UIFont boldSystemFontOfSize:14] : [UIFont boldSystemFontOfSize:17];
}

+ (UIFont *)navigationItemsFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:17];
}

+ (UIFont *)tableViewCellTitleFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:17];
}

+ (UIFont *)tableViewCellDetailFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:17];
}

+ (UIFont *)tableViewCellDetailErrorFont
{
    return [JMUtils isIphone] ? [UIFont italicSystemFontOfSize:10] : [UIFont italicSystemFontOfSize:16];
}

+ (UIFont *)resourcesActivityTitleFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:20] : [UIFont systemFontOfSize:30];
}

+ (UIFont *)collectionResourceNameFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:22];
}

+ (UIFont *)collectionResourceDescriptionFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:14];
}

+ (UIFont *)collectionLoadingFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:20] : [UIFont systemFontOfSize:30];
}


+ (UIFont *)menuItemTitleFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:20];
}

+ (UIFont *)menuItemDescriptionFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:15];
}

+ (UIFont *)loginInputControlsFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:18];
}

@end


@implementation JMThemesManager (UIColor)
// Login View
- (UIColor *)loginViewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginViewBackgroundColor];
    return [self collectionViewBackgroundColor];
}

- (UIColor *)loginViewPlaceholderBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginViewPlaceholderBackgroundColor];
}

- (UIColor *)loginViewTextFieldsBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginViewTextFieldsBackgroundColor];
}

- (UIColor *)loginViewTextFieldsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginViewTextFieldsTextColor];
}

- (UIColor *)loginViewLoginButtonBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginLoginButtonBackgroundColor];
}

- (UIColor *)loginViewLoginButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginLoginButtonTextColor];
}

- (UIColor *)loginViewTryDemoButtonBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginTryDemoButtonBackgroundColor];
}

- (UIColor *)loginViewTryDemoButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginTryDemoButtonTextColor];
}

// Menu View
- (UIColor *)menuViewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewBackgroundColor];
}

- (UIColor *)menuViewTextColorColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewTextColor];
}

- (UIColor *)menuViewSelectedTextColorColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewSelectedTextColor];
}

- (UIColor *)menuViewSeparatorColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewSeparatorColor];
}


// Server Profiles
- (UIColor *)serversViewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeServerProfilesBackgroundColor];
}

- (UIColor *)serverProfilePreviewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeServerProfilePreviewBackgroundColor];
}

- (UIColor *)serverProfileTitleTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeServerProfileTitleTextColor];
}

- (UIColor *)serverProfileDetailsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeServerProfileDetailsTextColor];
}

- (UIColor *)serverProfileSaveButtonBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeServerProfileSaveButtonBackgroundColor];
}

- (UIColor *)serverProfileSaveButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeServerProfileSaveButtonTextColor];
}


- (UIColor *)collectionViewBackgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];
}

// Common
- (UIColor *)viewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeViewBackgroundColor];
}

- (UIColor *)barsBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeBarsBackgroundColor];
}

- (UIColor *)barItemsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeBarItemsTextColor];
}

- (UIColor *)popupsBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemePopupsBackgroundColor];
}

- (UIColor *) tableViewCellTitleColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTableViewCellTitleColor];
}

- (UIColor *) tableViewCellErrorColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTableViewCellErrorColor];
}

- (UIColor *) textFieldBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTextFieldBackgroundColor];
}

- (UIColor *) textFieldEditableTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTextFieldEditableTextColor];
}

- (UIColor *) textFieldUnEditableTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTextFieldUnEditableTextColor];
}








@end