//
//  JMMakeActiveServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/8/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMMakeActiveServerOptionCell.h"

@implementation JMMakeActiveServerOptionCell

- (void)checkButtonTapped:(id)sender
{
    [super checkButtonTapped:sender];
    [self.delegate performSelector:@selector(makeActiveButtonTappedOnTableViewCell:) withObject:self];
}

- (void) discardActivityServer
{
    self.checkBoxButton.selected = NO;
    self.serverOption.optionValue = [NSNumber numberWithBool:NO];
}

@end
