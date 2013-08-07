//
//  JMDashboardViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 8/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourceClientHolder.h"

@interface JMDashboardViewController : UIViewController <JMResourceClientHolder, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
