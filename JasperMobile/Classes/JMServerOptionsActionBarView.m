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
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *makeActiveButton;
@end


@implementation JMServerOptionsActionBarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.saveButton setTitle:JMCustomLocalizedString(@"action.button.apply", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:JMCustomLocalizedString(@"action.button.cancel", nil) forState:UIControlStateNormal];
    [self.deleteButton setTitle:JMCustomLocalizedString(@"action.button.delete", nil) forState:UIControlStateNormal];
    [self.makeActiveButton setTitle:JMCustomLocalizedString(@"action.button.makeactive", nil) forState:UIControlStateNormal];
}

- (IBAction)saveButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Apply];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Cancel];
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Delete];
}

- (IBAction)makeActiveButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_MakeActive];
}

- (void)setDisabledAction:(JMBaseActionBarViewAction)disabledAction
{
    [super setDisabledAction:disabledAction];
    if (disabledAction & JMBaseActionBarViewAction_Delete) {
        self.deleteButton.enabled = NO;
    }
    if (disabledAction & JMBaseActionBarViewAction_MakeActive) {
        self.makeActiveButton.enabled = NO;
    }
}
@end
