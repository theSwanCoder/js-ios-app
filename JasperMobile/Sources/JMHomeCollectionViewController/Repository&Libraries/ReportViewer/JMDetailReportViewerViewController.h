//
//  JMDetailReportViewerViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMResourceClientHolder.h"
#import "JMReportClientHolder.h"

@interface JMDetailReportViewerViewController : UIViewController <JMResourceClientHolder, JMReportClientHolder, JMRefreshable>

@property (nonatomic, strong) NSMutableArray *inputControls;
@end
