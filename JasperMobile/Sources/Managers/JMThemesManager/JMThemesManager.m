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
//  JMThemesManager.m
//  TIBCO JasperMobile
//


#import "JMThemesManager.h"
#import "JasperMobileAppDelegate.h"

#import "UIColor+RGBComponent.h"
#import "JMConstants.h"
#import "JMUtils.h"

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
NSString * const kJMThemeLoginTryDemoButtonDisabledBackgroundColor = @"LoginView.trydemo_button_disabled_background_color";
NSString * const kJMThemeLoginTryDemoButtonTextColor = @"LoginView.trydemo_button_text_color";
NSString * const kJMThemeLoginTryDemoDisabledButtonTextColor = @"LoginView.trydemo_disabled_button_text_color";

// Menu View
NSString * const kJMThemeMenuViewBackgroundColor = @"MenuView.background_color";
NSString * const kJMThemeMenuViewTextColor = @"MenuView.text_color";
NSString * const kJMThemeMenuViewUserNameTextColor = @"MenuView.user_name_text_color";
NSString * const kJMThemeMenuViewAdditionalInfoTextColor = @"MenuView.additional_info_text_color";

NSString * const kJMThemeMenuViewSelectedTextColor = @"MenuView.selected_text_color";
NSString * const kJMThemeMenuViewSeparatorColor = @"MenuView.separator_color";

//Server Profiles
NSString * const kJMThemeServerProfilesBackgroundColor = @"ServerProfiles.background_color";
NSString * const kJMThemeServerProfilePreviewBackgroundColor = @"ServerProfiles.profile_preview_background_color";
NSString * const kJMThemeServerProfileTitleTextColor = @"ServerProfiles.profile_title_text_color";
NSString * const kJMThemeServerProfileDetailsTextColor = @"ServerProfiles.profile_details_text_color";
NSString * const kJMThemeServerProfileSaveButtonBackgroundColor = @"ServerProfiles.save_button_background_color";
NSString * const kJMThemeServerProfileSaveButtonTextColor = @"ServerProfiles.save_button_text_color";

// Resource View
NSString * const kJMThemeResourceViewBackgroundColor = @"ResourceView.background_color";
NSString * const kJMThemeResourceViewLoadingCellTitleTextColor = @"ResourceView.loading_cell_title_text_color";
NSString * const kJMThemeResourceViewLoadingCellActivityIndicatorColor = @"ResourceView.loading_cell_activity_indicator_color";
NSString * const kJMThemeResourceViewResourceCellTitleTextColor = @"ResourceView.resource_cell_title_text_color";
NSString * const kJMThemeResourceViewResourceCellDetailsTextColor = @"ResourceView.resource_cell_details_text_color";
NSString * const kJMThemeResourceViewResourceCellPreviewBackgroundColor = @"ResourceView.resource_cell_preview_background_color";
NSString * const kJMThemeResourceViewNoResultLabelTextColor = @"ResourceView.noresult_label_text_color";
NSString * const kJMThemeResourceViewActivityLabelTextColor = @"ResourceView.activity_label_text_color";
NSString * const kJMThemeResourceViewActivityActivityIndicatorColor = @"ResourceView.activity_activity_indicator_color";
NSString * const kJMThemeResourceViewRefreshControlTintColor = @"ResourceView.refresh_control_tint_color";
NSString * const kJMThemeResourceViewResourceInfoButtonTintColor = @"ResourceView.resource_info_button_tint_color";
NSString * const kJMThemeResourceViewResourceFavoriteBattonTintColor = @"ResourceView.resource_favorite_button_tint_color";

// Report Options
NSString * const kJMThemeReportOptionsRunReportButtonBackgroundColor = @"ReportOptions.runreport_button_background_color";
NSString * const kJMThemeReportOptionsRunReportButtonTextColor = @"ReportOptions.runreport_button_text_color";
NSString * const kJMThemeReportOptionsTitleLabelTextColor = @"ReportOptions.title_label_text_color";
NSString * const kJMThemeReportOptionsNoResultLabelTextColor = @"ReportOptions.noresult_label_text_color";
NSString * const kJMThemeReportOptionsItemsSegmentedControlTintColor = @"ReportOptions.items_segmented_control_tint_color";


// Save Report
NSString * const kJMThemeSaveReportSaveReportButtonBackgroundColor = @"SaveReport.savereport_button_background_color";
NSString * const kJMThemeSaveReportSaveReportButtonTextColor = @"SaveReport.savereport_button_text_color";

// About App
NSString * const kJMThemeAboutAppAppNameTextColorColor = @"AboutApp.app_name_text_color";
NSString * const kJMThemeAboutAppAppAboutTextColor = @"AboutApp.app_about_text_color";
NSString * const kJMThemeAboutAppButtonsBackgroundColor = @"AboutApp.buttons_background_color";
NSString * const kJMThemeAboutAppButtonsTextColor = @"AboutApp.buttons_text_color";


// Common
NSString * const kJMThemeViewBackgroundColor = @"Common.views_background_color";
NSString * const kJMThemeBarsBackgroundColor = @"Common.bars_background_color";
NSString * const kJMThemeBarItemsColor = @"Common.bar_items_text_color";
NSString * const kJMThemePopupsBackgroundColor = @"Common.popups_background_color";
NSString * const kJMThemePopupsTextColor = @"Common.popups_text_color";
NSString * const kJMThemeTableViewCellTitleTextColor = @"Common.table_view_cell_title_text_color";
NSString * const kJMThemeTableViewCellDetailsTextColor = @"Common.table_view_cell_details_text_color";
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

    
    
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[self barItemsColor]}];
    [[UINavigationBar appearance] setTintColor:[self barItemsColor]];
    [[UIToolbar appearance] setTintColor: [self barItemsColor]];
    
    NSDictionary *textTitleOptions = @{NSForegroundColorAttributeName : [self barItemsColor], NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    
    if ([UIDevice currentDevice].systemVersion.integerValue < 8) {
        // Here is hack for using UIPrintInteractionController
        NSDictionary *textTitleOptionsForPopover = @{NSForegroundColorAttributeName : [self barsBackgroundColor], NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
        [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:textTitleOptionsForPopover];
    }
    
    NSDictionary *barButtonTitleOptions = @{NSForegroundColorAttributeName : [self barItemsColor], NSFontAttributeName : [[JMThemesManager sharedManager] navigationItemsFont]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitleTextAttributes:nil forState:UIControlStateNormal];
    
    
    
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
        NSDictionary *attributeDictionary = [themeDictionary valueForKeyPath:keyPath];
        
        if (attributeDictionary && [attributeDictionary count] >= 2) {
            id attributeType  = attributeDictionary[kJMThemeAttributeTypeKey];
            id attributeValue = attributeDictionary[kJMThemeAttributeValueKey];
            if (attributeType && attributeValue && [attributeType isKindOfClass:[NSString class]]) {
                if ([attributeType isEqualToString:kJMThemeAttributeTypeColor]) {
                    if ([attributeValue isKindOfClass:[NSString class]]) {
                        
                        // Fix for implementing color from image pattern
                        UIImage *imagePattern = [UIImage imageNamed:attributeValue];
                        if (imagePattern) {
                            return [UIColor colorWithPatternImage:imagePattern];
                        }
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
                                            @(traits)}}];
    NSArray* matches = [fd matchingFontDescriptorsWithMandatoryKeys:
                        [NSSet setWithObjects:UIFontDescriptorFamilyAttribute, UIFontDescriptorTraitsAttribute, nil]];
    if (matches.count == 0) return nil;
    return [UIFont fontWithDescriptor:matches[0] size:pointSize];
}

@end

@implementation JMThemesManager (UIFont)

- (UIFont *)navigationBarTitleFont
{
    return [UIFont boldSystemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 14 : 17];
}

- (UIFont *)navigationItemsFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 14 : 17];
}

- (UIFont *)tableViewCellTitleFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 14 : 17];
}

- (UIFont *)tableViewCellDetailFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 14 : 17];
}

- (UIFont *)tableViewCellErrorFont
{
    return [UIFont italicSystemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 10 : 16];
}

- (UIFont *)resourcesActivityTitleFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 20 : 30];
}

- (UIFont *)collectionResourceNameFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 15 : 22];
}

- (UIFont *)collectionResourceDescriptionFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 12 : 14];
}

- (UIFont *)collectionLoadingFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 20 : 30];
}

- (UIFont *)menuItemTitleFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 16 : 20];
}

- (UIFont *)menuItemDescriptionFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 12 : 15];
}

- (UIFont *)loginInputControlsFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 15 : 18];
}


- (UIFont *)appAboutTitleFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 16 : 22];
}

- (UIFont *)appAboutCommonTextFont
{
    return [UIFont systemFontOfSize:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 14 : 18];
}

@end


@implementation JMThemesManager (UIColor)
// Login View
- (UIColor *)loginViewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginViewBackgroundColor];
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

- (UIColor *)loginViewTryDemoButtonDisabledBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginTryDemoButtonDisabledBackgroundColor];
}

- (UIColor *)loginViewTryDemoButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginTryDemoButtonTextColor];
}

- (UIColor *)loginViewTryDemoDisabledButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeLoginTryDemoDisabledButtonTextColor];
}

// Menu View
- (UIColor *)menuViewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewBackgroundColor];
}

- (UIColor *)menuViewUserNameTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewUserNameTextColor];
}

- (UIColor *)menuViewAdditionalInfoTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewAdditionalInfoTextColor];
}

- (UIColor *)menuViewTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeMenuViewTextColor];
}

- (UIColor *)menuViewSelectedTextColor
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

// Resource View
- (UIColor *)resourceViewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewBackgroundColor];
}

- (UIColor *)resourceViewLoadingCellTitleTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewLoadingCellTitleTextColor];
}

- (UIColor *)resourceViewLoadingCellActivityIndicatorColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewLoadingCellActivityIndicatorColor];
}

- (UIColor *)resourceViewResourceCellTitleTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewResourceCellTitleTextColor];
}

- (UIColor *)resourceViewResourceCellDetailsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewResourceCellDetailsTextColor];
}

- (UIColor *)resourceViewResourceCellPreviewBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewResourceCellPreviewBackgroundColor];
}

- (UIColor *)resourceViewNoResultLabelTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewNoResultLabelTextColor];
}

- (UIColor *)resourceViewActivityLabelTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewActivityLabelTextColor];
}

- (UIColor *)resourceViewActivityActivityIndicatorColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewActivityActivityIndicatorColor];
}

- (UIColor *)resourceViewRefreshControlTintColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewRefreshControlTintColor];
}

- (UIColor *)resourceViewResourceInfoButtonTintColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewResourceInfoButtonTintColor];
}

- (UIColor *)resourceViewResourceFavoriteButtonTintColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeResourceViewResourceFavoriteBattonTintColor];
}

// Report Options
- (UIColor *)reportOptionsRunReportButtonBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeReportOptionsRunReportButtonBackgroundColor];
}

- (UIColor *)reportOptionsRunReportButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeReportOptionsRunReportButtonTextColor];
}

- (UIColor *)reportOptionsTitleLabelTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeReportOptionsTitleLabelTextColor];
}

- (UIColor *)reportOptionsNoResultLabelTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeReportOptionsNoResultLabelTextColor];
}

- (UIColor *)reportOptionsItemsSegmentedTintColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeReportOptionsItemsSegmentedControlTintColor];
}

// Save Report
- (UIColor *)saveReportSaveReportButtonBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeSaveReportSaveReportButtonBackgroundColor];
}

- (UIColor *)saveReportSaveReportButtonTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeSaveReportSaveReportButtonTextColor];
}

// About App
- (UIColor *)aboutAppAppNameTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeAboutAppAppNameTextColorColor];
}

- (UIColor *)aboutAppAppAboutTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeAboutAppAppAboutTextColor];
}

- (UIColor *)aboutAppButtonsBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeAboutAppButtonsBackgroundColor];
}

- (UIColor *)aboutAppButtonsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeAboutAppButtonsTextColor];
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

- (UIColor *)barItemsColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeBarItemsColor];
}

- (UIColor *)popupsBackgroundColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemePopupsBackgroundColor];
}

- (UIColor *)popupsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemePopupsTextColor];
}

- (UIColor *) tableViewCellTitleTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTableViewCellTitleTextColor];
}

- (UIColor *) tableViewCellDetailsTextColor
{
    return [self attributeValueFromDictionary:self.themesDictionary forKeyPath:kJMThemeTableViewCellDetailsTextColor];
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