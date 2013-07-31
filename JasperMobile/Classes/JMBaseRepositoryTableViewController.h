//
//  JMRepositoryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/27/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMResourceClientHolder.h"
#import "JMResourceTableViewController.h"
#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

@interface JMBaseRepositoryTableViewController : UITableViewController <JMResourceClientHolder, JSRequestDelegate, JMResourceTableViewControllerDelegate>

@property (nonatomic, strong) JSConstants *constants;

@end
