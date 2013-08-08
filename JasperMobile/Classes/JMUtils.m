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
//  JMUtils.m
//  Jaspersoft Corporation
//

#import "JMUtils.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "Reachability.h"

@implementation JMUtils

+ (void)setTitleForResourceViewController:(UIViewController<JMResourceClientHolder> *)viewController
{
    viewController.navigationItem.title = viewController.resourceDescriptor.label ?: viewController.resourceClient.serverProfile.alias;
}

+ (void)setBackgroundImagesForButton:(UIButton *)button imageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName edgesInset:(CGFloat)edgesInset
{
    UIEdgeInsets capInsets = UIEdgeInsetsMake(edgesInset, edgesInset, edgesInset, edgesInset);
    UIImage *image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets];
    UIImage *highlightedImage = [[UIImage imageNamed:highlightedImageName] resizableImageWithCapInsets:capInsets];
    
    if (image) {
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    if (highlightedImage) {
        [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
}

+ (NSString *)localizedTitleForMenuItemByTag:(NSInteger)tag {
    NSString *title = @"";
    
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
        case kJMServersMenuTag:
            title = @"view.servers";
    }
    
    return JMCustomLocalizedString(title, nil);
}

+ (void)sendChangeServerProfileNotificationWithProfile:(JMServerProfile *)serverProfile
{
    NSDictionary *userInfo = serverProfile ? @{
        kJMServerProfileKey : serverProfile
    } : nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMChangeServerProfileNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (BOOL)isNetworkReachable
{
    NetworkStatus networkStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) return YES;
    
    networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    return networkStatus == ReachableViaWWAN;
}

@end
