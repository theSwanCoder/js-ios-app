//
//  UIViewController+JMMainNavigationItem.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/6/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JMMainNavigationItem) {
    JMMainNavigationItem_Left = 1,
    JMMainNavigationItem_Title,
    JMMainNavigationItem_Right,
    JMMainNavigationItem_All = JMMainNavigationItem_Left | JMMainNavigationItem_Right | JMMainNavigationItem_Title
};

@interface UIViewController (JMMainNavigationItem)
- (void) viewController:(id)viewController setNeedsUpdateMainNavigationItem:(JMMainNavigationItem)item;

@end
