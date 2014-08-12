//
//  JMMasterResourcesTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMPagination.h"
#import "JMResourceClientHolder.h"
#import "JMBackHeaderView.h"

// TODO: refactor, remove code duplications. Create Base View Controller and extends from it
@interface JMMasterResourcesTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JMPagination, JMResourceClientHolder>

@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, strong) NSString *sortBy;
@property (nonatomic, assign) BOOL loadRecursively;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet JMBackHeaderView *backView;
@property (nonatomic, assign) NSInteger selectedResourceIndex;

@end
