//
//  JMDetailReportOptionsActionBarView.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 7/14/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailReportOptionsActionBarView.h"
#import "JMLocalization.h"

@implementation JMDetailReportOptionsActionBarView

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.cancelButton.titleLabel.text = JMCustomLocalizedString(@"dialog.button.cancel", nil);
    self.continueButton.titleLabel.text = JMCustomLocalizedString(@"dialog.button.continue", nil);
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.delegate cancel];
}

- (IBAction)runReport:(id)sender
{
    [self.delegate runReport];
}

@end
