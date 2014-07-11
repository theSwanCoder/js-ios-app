//
//  JMDetailSettingsActionBarView.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSettingsActionBarView.h"

@interface JMDetailSettingsActionBarView ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *actionButtonColections;

@end

@implementation JMDetailSettingsActionBarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.actionButtonColections makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:kJMDetailActionBarItemsBackgroundColor];
}

- (IBAction)saveButtonTapped:(id)sender
{
    [self.delegate saveButtonTappedInActionView:self];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate cancelButtonTappedInActionView:self];
}

@end
