//
//  JMMasterLibraryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourceClientHolder.h"

// TODO: make universal view controller. Extend it for Library usage
@interface JMMasterLibraryTableViewController : UITableViewController <JMResourceClientHolder>

@property (nonatomic, weak) JSConstants *constants;

@end
