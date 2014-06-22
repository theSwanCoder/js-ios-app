//
//  JMResourcesRepresentationSwitcherActionBarView.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/19/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMDetailRootViewController;

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationTypeGrid = 1,
    JMResourcesRepresentationTypeHorizontalList = 2,
    JMResourcesRepresentationTypeVerticalList = 3
};

static inline JMResourcesRepresentationType JMResourcesRepresentationTypeFirst() { return JMResourcesRepresentationTypeGrid; }
static inline JMResourcesRepresentationType JMResourcesRepresentationTypeLast() { return JMResourcesRepresentationTypeVerticalList; }

@interface JMResourcesRepresentationSwitcherActionBarView : UIView

@property (nonatomic, weak) JMDetailRootViewController *delegate;

@end
