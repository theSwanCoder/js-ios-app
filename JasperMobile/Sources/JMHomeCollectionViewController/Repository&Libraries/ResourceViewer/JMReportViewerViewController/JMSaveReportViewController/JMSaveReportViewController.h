//
//  JMSaveReportViewController.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMEditabledViewController.h"
#import "JMResourceClientHolder.h"
#import "JMReportClientHolder.h"

extern NSString * const kJMSaveReportViewControllerSegue;

@interface JMSaveReportViewController : JMEditabledViewController <JMResourceClientHolder, JMReportClientHolder>
@property (nonatomic, strong) NSMutableArray *inputControls;
@property (nonatomic, weak) UIViewController *delegate;

@end
