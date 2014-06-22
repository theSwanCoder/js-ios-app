//
//  JMResourcesRepresentationSwitcherActionBarView.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/19/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourcesRepresentationSwitcherActionBarView.h"
#import "JMDetailRootViewController.h"

@implementation JMResourcesRepresentationSwitcherActionBarView

#pragma mark - Accessors

- (void)setDelegate:(JMDetailRootViewController *)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        UIButton *button = (UIButton*) [self viewWithTag:delegate.representationType];
        [button setEnabled:NO];
    }
}

#pragma mark - Actions

- (IBAction)changeRepresentation:(id)sender
{
    for (NSInteger i = JMResourcesRepresentationTypeFirst(); i <= JMResourcesRepresentationTypeLast(); i++) {
        UIButton *button = (UIButton *) [self viewWithTag:i];
        [button setEnabled:YES];
    }
    
    [sender setEnabled:NO];
    self.delegate.representationType = (JMResourcesRepresentationType) [sender tag];
}

@end
