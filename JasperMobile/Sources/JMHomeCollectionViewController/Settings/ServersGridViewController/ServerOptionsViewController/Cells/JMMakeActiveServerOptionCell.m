//
//  JMMakeActiveServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/8/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMMakeActiveServerOptionCell.h"

@interface JMMakeActiveServerOptionCell ()
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *makeActiveButton;

@end

@implementation JMMakeActiveServerOptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.makeActiveButton setTitle:JMCustomLocalizedString(@"servers.button.makeactive", nil) forState:UIControlStateNormal];
    [self.makeActiveButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.makeActiveButton setTitleColor:kJMDetailActionBarItemsTextColor forState:UIControlStateDisabled];
    [self.makeActiveButton setTitleColor:kJMDetailActionBarItemsTextColor forState:UIControlStateHighlighted];
    [self.makeActiveButton setTitleColor:kJMDetailActionBarItemsTextColor forState:UIControlStateSelected];
}

-(void)setServerOption:(JMServerOption *)serverOption
{
    [super setServerOption:serverOption];
    
    NSString *keyString = [serverOption.optionValue boolValue] ? @"ic.value.yes" : @"ic.value.no";
    self.valueLabel.text = JMCustomLocalizedString(keyString, nil);
    self.makeActiveButton.enabled = ![serverOption.optionValue boolValue];
}

- (IBAction)makeActiveButtonTapped:(id)sender
{
    [self.delegate makeActiveButtonTappedOnTableViewCell:self];
}

@end
