//
//  JMDetailReportViewerViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMReportViewerViewController.h"
#import "JMActionBarProvider.h"
#import "JMRefreshable.h"
#import "JMInputControlsHolder.h"
#import "JMResourceClientHolder.h"

@interface JMDetailReportViewerViewController : JMReportViewerViewController <JMActionBarProvider, JMResourceClientHolder,
    JMInputControlsHolder, JMRefreshable>

@end
