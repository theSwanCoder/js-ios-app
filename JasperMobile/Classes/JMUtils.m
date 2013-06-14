//
//  JMViewControllerHelper.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMUtils.h"
#import <Objection-iOS/Objection.h>

@implementation JMUtils

+ (void)awakeFromNibForResourceViewController:(UIViewController <JMResourceClientHolder>*)viewController
{
    [[JSObjection defaultInjector] injectDependencies:viewController];
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

@end
