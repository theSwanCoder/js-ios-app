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

// TODO: refactor, remove code duplications. Create Base View Controller and extends from it
@interface JMMasterResourcesTableViewController : UITableViewController <JMPagination, JMResourceClientHolder>

@property (nonatomic, copy) NSMutableArray *resources;
@property (nonatomic, strong) NSArray *resourcesTypes;

@end
