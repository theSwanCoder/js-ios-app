//
//  JMServersActionBarView.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/23/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServersActionBarView.h"
#import "JMLocalization.h"

@interface JMServersActionBarView()
@property (nonatomic, weak) IBOutlet UIButton *createServerButton;
@end

@implementation JMServersActionBarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.createServerButton.titleLabel.text = JMCustomLocalizedString(@"action.button.newserver", nil);
}

- (IBAction)newServer:(id)sender
{
    [self.delegate actionView:self didSelectAction:JMBaseActionBarViewAction_Create];
}

@end
