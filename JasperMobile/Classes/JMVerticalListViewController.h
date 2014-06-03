//
//  JMVerticalListViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMDetailRootViewController.h"

@interface JMVerticalListViewController : UITableViewController <JMRefreshable>

@property (nonatomic, weak) JMDetailRootViewController *delegate;

@end
