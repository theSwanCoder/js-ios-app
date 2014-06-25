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

@class JMDetailActivityIndicatorView;
@class JMDetailNoResultsView;

@interface JMDetailRootViewController : UIViewController <JMActionBarProvider, JMResourceClientHolder, JMPagination>

@property (nonatomic, assign) JMResourcesRepresentationType representationType;
@property (nonatomic, assign) BOOL loadRecursively;
@property (nonatomic, weak) IBOutlet JMDetailActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet JMDetailNoResultsView *noResultsView;

@end

@interface JMDetailActivityIndicatorView : UIView
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@interface JMDetailNoResultsView : UIView
@property (nonatomic, weak) IBOutlet UILabel *label;
@end
