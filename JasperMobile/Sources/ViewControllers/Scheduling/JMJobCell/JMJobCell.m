//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMJobCell.h"


@implementation JMJobCell

#pragma mark - Actions
- (IBAction)deleteJob:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(jobCellDidReceiveDeleteJobAction:)]) {
        [self.delegate jobCellDidReceiveDeleteJobAction:self];
    }
}

@end