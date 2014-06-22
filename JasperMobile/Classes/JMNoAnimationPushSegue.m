//
//  JMNoAnimationPushSegue.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/20/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMNoAnimationPushSegue.h"

@implementation JMNoAnimationPushSegue

- (void)perform
{
    [[self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:NO];
}

@end
