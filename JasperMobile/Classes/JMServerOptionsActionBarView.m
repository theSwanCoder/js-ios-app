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
    [self.saveButton setTitle:JMCustomLocalizedString(@"action.button.apply", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:JMCustomLocalizedString(@"action.button.cancel", nil) forState:UIControlStateNormal];
}

- (IBAction)saveButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Apply];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Cancel];
}

@end
