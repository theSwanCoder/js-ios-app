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
#import "JMActionBarProvider.h"

// TODO: make universal view controller or avoid code duplications in other way
@interface JMVerticalListViewController : UITableViewController <JMRefreshable, JMActionBarProvider>

@property (nonatomic, weak) UIViewController <JMPagination, JMResourceClientHolder, JMActionBarProvider> *delegate;
@property (nonatomic, weak) JSConstants *constants;

@end
