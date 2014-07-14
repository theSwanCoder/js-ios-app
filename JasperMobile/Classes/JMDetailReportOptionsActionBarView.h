//
//  JMDetailReportOptionsActionBarView.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 7/14/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMDetailReportOptionsViewController.h"

@interface JMDetailReportOptionsActionBarView : UIView

@property (nonatomic, weak) JMDetailReportOptionsViewController *delegate;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end
