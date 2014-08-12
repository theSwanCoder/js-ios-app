//
//  JMVerticalListViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMPagination.h"
#import "JMResourceClientHolder.h"
#import "JMBaseResourcesViewController.h"

@interface JMVerticalListViewController : JMBaseResourcesViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) UIViewController <JMPagination, JMResourceClientHolder, JMActionBarProvider> *delegate;
@property (nonatomic, weak) JSConstants *constants;

@end
