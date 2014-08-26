/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMUtils.m
//  Jaspersoft Corporation
//

#import "JMUtils.h"
#import "JMConstants.h"
#import "JMLocalization.h"

CGFloat kJMNoEdgesInset = -1;

@implementation JMUtils

+ (void)setTitleForResourceViewController:(UIViewController<JMResourceClientHolder> *)viewController
{
    viewController.navigationItem.title = viewController.resourceLookup.label ?: viewController.resourceClient.serverProfile.alias;
}

+ (void)setBackgroundImagesForButton:(UIButton *)button imageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName edgesInset:(CGFloat)edgesInset
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *highlightedImage = [UIImage imageNamed:highlightedImageName];

    if (edgesInset != kJMNoEdgesInset) {
        UIEdgeInsets capInsets = UIEdgeInsetsMake(edgesInset, edgesInset, edgesInset, edgesInset);
        image = [image resizableImageWithCapInsets:capInsets];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:capInsets];
    }
    
    if (image) {
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }

    if (highlightedImage) {
        [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
}

+ (NSString *)localizedTitleForMenuItemByTag:(NSInteger)tag {
    NSString *title;
    
    switch (tag) {
        case kJMLibraryMenuTag:
            title = @"view.library";
            break;
        case kJMRepositoryMenuTag:
            title = @"view.repository";
            break;
        case kJMFavoritesMenuTag:
            title = @"view.favorites";
            break;
        case kJMSavedReportsMenuTag:
            title = @"view.savedreports";
            break;
        case kJMServersMenuTag:
        default:
            title = @"view.servers";
    }
    
    return JMCustomLocalizedString(title, nil);
}

+ (BOOL)isViewControllerVisible:(UIViewController *)viewController
{
    return viewController.isViewLoaded && viewController.view.window;
}

#define kJMNameMin 1
#define kJMNameMax 250
#define kJMInvalidCharacters @":/"
+ (BOOL)validateReportName:(NSString *)reportName extension:(NSString *)extension errorMessage:(NSString **)errorMessage
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:kJMInvalidCharacters];

    if (reportName.length < kJMNameMin) {
        *errorMessage = JMCustomLocalizedString(@"savereport.name.errmsg.empty", nil);
    } else if (reportName.length > kJMNameMax) {
        *errorMessage = [NSString stringWithFormat:JMCustomLocalizedString(@"savereport.name.errmsg.maxlength", nil), kJMNameMax];
    } else if ([reportName rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
        *errorMessage = JMCustomLocalizedString(@"savereport.name.errmsg.characters", nil);
    } else {
        if (extension) {
            reportName = [reportName stringByAppendingPathExtension:extension];
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *reportPath = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:reportName];

        if ([fileManager fileExistsAtPath:reportPath]) {
            *errorMessage = JMCustomLocalizedString(@"savereport.name.errmsg.notunique", nil);
        }
    }

    return [*errorMessage length] == 0;
}

+ (NSString *)documentsReportDirectoryPath
{
    static NSString *reportDirectory;
    if (!reportDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        reportDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", kJMReportsDirectory]];
    }

    return reportDirectory;
}

+ (void)sendChangeServerProfileNotificationWithProfile:(JMServerProfile *)serverProfile withParams:(NSDictionary *)params
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:params];
    if (serverProfile) {
        [userInfo setObject:serverProfile forKey:kJMServerProfileKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMChangeServerProfileNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showNetworkActivityIndicator
{
    UIApplication *application = [UIApplication sharedApplication];
    if (!application.networkActivityIndicatorVisible) {
        application.networkActivityIndicatorVisible = YES;
    }
}

+ (void)hideNetworkActivityIndicator
{
    UIApplication *application = [UIApplication sharedApplication];
    if (application.networkActivityIndicatorVisible) {
        application.networkActivityIndicatorVisible = NO;
    }
}

@end
