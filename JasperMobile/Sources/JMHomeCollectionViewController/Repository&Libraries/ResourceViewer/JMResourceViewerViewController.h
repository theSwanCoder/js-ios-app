//
//  JMResourceViewerViewController.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourceClientHolder.h"
#import "JMResourceViewerActionsView.h"

@interface JMResourceViewerViewController : UIViewController <UIWebViewDelegate, JMResourceClientHolder, JMResourceViewerActionsViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL isRequestLoaded;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSMutableArray *inputControls;

- (void) runReportExecution;

- (JMResourceViewerAction)availableAction;

@end
