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
#import "JMRefreshable.h"

@interface JMDetailReportOptionsViewController : UIViewController <JMReportClientHolder, JMResourceClientHolder, JMInputControlsHolder>

@property (nonatomic, weak) id <JMReportClientHolder, JMInputControlsHolder, JMResourceClientHolder, JMRefreshable> delegate;

@end
