//
//  JMReportOptionsTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 8/19/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMReportClientHolder.h"
#import "JMResourceClientHolder.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>

@interface JMReportOptionsTableViewController : UITableViewController <JMReportClientHolder, JMResourceClientHolder, JSRequestDelegate>

@property (nonatomic, strong) JSConstants *constants;
@property (nonatomic, strong) NSMutableArray *inputControls;

@end
