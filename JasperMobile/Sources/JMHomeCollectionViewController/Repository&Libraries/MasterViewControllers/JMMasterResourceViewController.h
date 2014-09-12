//
//  JMMasterResourceViewController.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/5/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSearchable.h"
#import "JMRefreshable.h"

@interface JMMasterResourceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JMSearchable, JMRefreshable>
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView  *masterMenuTitleView;
@property (nonatomic, strong) NSString *searchQuery;

- (void)loadResourcesIntoDetailViewController;

- (NSDictionary *)paramsForLoadingResourcesIntoDetailViewController;

@end
