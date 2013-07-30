//
//  JMViewControllerHelper.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"
#import "JMServerProfile.h"

@interface JMUtils : NSObject

/**
 Sets title equal to resource's name or profile's alias if resource is <b>nil</b>
 
 @param viewController A viewController for which title will be set
 */
+ (void)setTitleForResourceViewController:(UIViewController <JMResourceClientHolder>*)viewController;

/**
 Sets background images to the button.
 
 @param button The button for which background images will be set
 @param imageName A name of the image for button's normal state (can be "nil")
 @param highlightedImageName A name of the image for button's highlighted state (can be "nil")
 @param edgesInset An inset for all edges
 */
+ (void)setBackgroundImagesForButton:(UIButton *)button imageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName edgesInset:(CGFloat)edgesInset;

/**
 Returns localized title for menu item (Library, Repository, Favorites etc) depends
 on item's tag
 
 @param tag A tag for the item
 */
+ (NSString *)localizedTitleForMenuItemByTag:(NSInteger)tag;

/**
 Sends "changeServerProfile" notification to defaultCenter
 
 @param serverProfile A profile that will be provided to receiver via userInfo dictionary (kJMServerProfileKey key)
 */
+ (void)sendChangeServerProfileNotificationWithProfile:(JMServerProfile *)serverProfile;

@end
