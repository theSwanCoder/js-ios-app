//
//  JMDetailNavigationViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/16/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMActionBarProvider.h"
#import "JMResourcesRepresentationSwitcherActionBarView.h"
#import "JMResourceClientHolder.h"
#import "JMPagination.h"

@interface JMDetailRootViewController : UIViewController <JMActionBarProvider, JMResourceClientHolder, JMPagination>

@property (nonatomic, assign) JMResourcesRepresentationType representationType;
@property (nonatomic, assign) BOOL loadRecursively;

@end
