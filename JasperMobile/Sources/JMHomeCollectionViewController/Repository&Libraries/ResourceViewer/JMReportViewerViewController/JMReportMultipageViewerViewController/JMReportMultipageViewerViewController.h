//
//  JMReportMultipageViewerViewController.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMResourceViewerViewController.h"
#import "JMRefreshable.h"

@interface JMReportMultipageViewerViewController : JMResourceViewerViewController <JMRefreshable>
- (void)setInputControls:(NSMutableArray *)inputControls;
@end
