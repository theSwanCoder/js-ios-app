//
//  JMMasterLibraryResourcesTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

// TODO: refactor, remove code duplications. Create Base View Controller and extends from it
@interface JMMasterLibraryResourcesTableViewController : UITableViewController

@property (nonatomic, weak) NSMutableArray *resources;

// Pagination properties
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger offset;

@end
