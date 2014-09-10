//
//  JMReportOptionsViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMEditabledViewController.h"
#import "JMRefreshable.h"


@interface JMReportOptionsViewController : JMEditabledViewController

@property (nonatomic, weak) id <JMResourceClientHolder, JMRefreshable> delegate;

@end
