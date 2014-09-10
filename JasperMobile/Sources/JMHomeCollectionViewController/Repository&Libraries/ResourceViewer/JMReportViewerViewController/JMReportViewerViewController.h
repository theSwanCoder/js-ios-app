//
//  JMReportViewerViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMReportClientHolder.h"
#import "JMResourceViewerViewController.h"

@interface JMReportViewerViewController : JMResourceViewerViewController <JMReportClientHolder, JMRefreshable>

@end
