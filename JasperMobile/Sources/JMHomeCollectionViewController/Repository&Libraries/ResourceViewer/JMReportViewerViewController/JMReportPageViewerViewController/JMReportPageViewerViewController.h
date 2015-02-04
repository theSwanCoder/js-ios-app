//
//  JMReportPageViewerViewController.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#include "JMReportLoader.h"

@interface JMReportPageViewerViewController : UIViewController
@property (nonatomic, assign) NSUInteger pageIndex;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (void)startLoadReportPageContentWithLoader:(JMReportLoader *)reportLoader;
- (void)startShowLoadProgress;
- (void)stopShowLoadProgress;
@end
