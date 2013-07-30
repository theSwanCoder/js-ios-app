//
//  JMViewControllerHelper.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMUtils.h"
#import "JMConstants.h"
#import "JMLocalization.h"

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

@end
