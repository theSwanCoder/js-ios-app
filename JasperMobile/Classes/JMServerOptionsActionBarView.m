//
//  JMServerOptionsActionBarView.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptionsActionBarView.h"

#import "JMLocalization.h"

@interface JMServerOptionsActionBarView ()
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end


@implementation JMServerOptionsActionBarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.saveButton.titleLabel.text   = JMCustomLocalizedString(@"action.button.save", nil);
    self.cancelButton.titleLabel.text   = JMCustomLocalizedString(@"action.button.cancel", nil);
}

- (IBAction)saveButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Save];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Cancel];
}

@end
