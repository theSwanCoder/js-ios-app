//
//  JMDetailReportViewerActionBarView.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/17/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailReportViewerActionBarView.h"
#import "JMLocalization.h"

@interface JMDetailReportViewerActionBarView ()
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end

@implementation JMDetailReportViewerActionBarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.refreshButton.titleLabel.text  = JMCustomLocalizedString(@"action.button.refresh", nil);
    self.shareButton.titleLabel.text    = JMCustomLocalizedString(@"action.button.share", nil);
    self.editButton.titleLabel.text     = JMCustomLocalizedString(@"action.button.edit", nil);
    self.deleteButton.titleLabel.text   = JMCustomLocalizedString(@"action.button.delete", nil);

}

- (void)setDisabledAction:(JMBaseActionBarViewAction)disabledAction{
    [super setDisabledAction:disabledAction];
    if (disabledAction & JMBaseActionBarViewAction_Edit) {
        self.editButton.enabled = NO;
    }
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Refresh];
}

- (IBAction)shareButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Share];
}

- (IBAction)editButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Edit];
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Delete];
}

@end
