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
    [((NSObject *)self.delegate) performSelector:@selector(makeActiveButtonTappedOnTableViewCell:) withObject:sender afterDelay:0.5];
}

@end
