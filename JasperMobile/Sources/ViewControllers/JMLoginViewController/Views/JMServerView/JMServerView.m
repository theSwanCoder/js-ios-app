//
//  JMServerView.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 11/12/15.
//  Copyright © 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMServerView.h"

@interface JMServerView()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation JMServerView

- (void)setTitle:(NSString *)title
{
    _title = title;
//    [self.button setTitle:title forState:UIControlStateNormal];
    self.titleLabel.text = title;
}

#pragma mark - Actions
- (IBAction)action:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(serverViewDidSelect:)]) {
        [self.delegate serverViewDidSelect:self];
    }
}


@end
