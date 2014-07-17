//
//  JMDetailReportOptionsActionBarView.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 7/14/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailReportOptionsActionBarView.h"
#import "JMLocalization.h"

@interface JMDetailReportOptionsActionBarView ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation JMDetailReportOptionsActionBarView

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.cancelButton.titleLabel.text = JMCustomLocalizedString(@"action.button.cancel", nil);
    self.continueButton.titleLabel.text = JMCustomLocalizedString(@"action.button.continue", nil);
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Cancel];
}

- (IBAction)runReport:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Run];
}

@end
