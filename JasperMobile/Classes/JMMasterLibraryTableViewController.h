//
//  JMMasterLibraryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMPaginable.h"
#import "JMResourceClientHolder.h"

@interface JMMasterLibraryTableViewController : UITableViewController <JMResourceClientHolder, JMPaginable>

@property (nonatomic, strong) NSString *folderUri;
@property (nonatomic, strong) NSMutableArray *resources;
@property (nonatomic, readonly) NSArray *resourcesType;
@property (nonatomic, weak) JSConstants *constants;

@end

@interface JMMenuTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *numberOfResources;
@property (nonatomic, weak) IBOutlet UIImageView *circleImageView;

@end
