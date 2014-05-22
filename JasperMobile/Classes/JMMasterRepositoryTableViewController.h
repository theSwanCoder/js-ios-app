//
//  JMMasterRepositoryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/13/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMPagination.h"
#import "JMResourceClientHolder.h"

@interface JMMasterRepositoryTableViewController : UITableViewController <JMPagination, JMResourceClientHolder>

@property (nonatomic, strong) NSMutableArray *folders;
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, weak) JMMasterRepositoryTableViewController *delegate;

@end
