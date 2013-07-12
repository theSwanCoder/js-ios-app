//
//  JMRepositoryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/27/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMResourceClientHolder.h"
#import "JMResourceViewController.h"

@interface JMBaseRepositoryTableViewController : UITableViewController <JMResourceClientHolder, JSRequestDelegate, JMResourceViewControllerDelegate>

@property (nonatomic, strong) JSConstants *constants;

@end
