//
//  JMDetailReportOptionsViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMInputControlsHolder.h"
#import "JMResourceClientHolder.h"
#import "JMReportClientHolder.h"
#import "JMActionBarProvider.h"

@interface JMDetailReportOptionsViewController : UIViewController <JMReportClientHolder, JMResourceClientHolder, JMInputControlsHolder, JMActionBarProvider, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL hasMandatoryInputControls;

- (void)updateInputControls;
- (void)cancel;

@end
