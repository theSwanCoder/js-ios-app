//
//  JMMasterTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourceClientHolder.h"

// TODO: make universal view controller. Extend it for Library usage
@interface JMMasterTableViewController : UITableViewController <JMResourceClientHolder>

@property (nonatomic, strong) NSString *folderUri;
@property (nonatomic, strong) NSMutableArray *resources;
@property (nonatomic, readonly) NSArray *resourcesType;
@property (nonatomic, weak) JSConstants *constants;
// Pagination properties
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger offset;

@end

@interface JMMenuTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *numberOfResources;
@property (nonatomic, weak) IBOutlet UIImageView *circleImageView;

@end
